require 'spec_helper'
require 'easy_mapper/model'

RSpec.describe EasyMapper do
  it 'has a version number' do
    expect(EasyMapper::VERSION).not_to be nil
  end

  let(:user_model) do
    Class.new do
      include EasyMapper::Model

      table_name 'Users'
      attributes :first_name, :age
    end
  end

  before(:all) do
    # TODO: auto start a test database

    EasyMapper::Config.db_adapter = EasyMapper::Adapters::PostgreAdapter.new(
      database: 'easy_mapper_test_db',
      user: 'easy_mapper_user',
      password: ''
    )
  end

  before(:each) do
    user_model.objects.delete_all
  end

  describe 'CRUD operations' do
    it 'saves a record in the database' do
      user = user_model.new(
        first_name: 'Pesho',
        age: 17
      )

      user.save

      actual = user_model.find_by_first_name('Pesho')
      expect(actual).to match_array [user]
    end

    it 'updates the record if id already exists' do
      user = user_model.new(
        first_name: 'Pesho',
        age: 20
      )

      user.save
      user.age = 21
      user.save

      actual = user_model.find_by_id(user.id)
      expect(actual).to eq [user]
    end

    it 'deletes a record' do
      user = user_model.new(
        first_name: 'Pesho',
        age: 20
      )

      user.save
      user.delete

      expect(user_model.find_by_first_name('Pesho')).to be_empty
    end
  end

  describe 'sorting' do
    it 'sorts by attribute in ascending order' do
      tosho = user_model.new(first_name: 'Tosho', age: 30).save
      pesho = user_model.new(first_name: 'Pesho', age: 20).save
      gosho = user_model.new(first_name: 'Gosho', age: 25).save

      actual = user_model.objects.order(age: :ASC).exec
      expect(actual == [pesho, gosho, tosho]).to be true
    end

    it 'sorts by attribute in descending order' do
      tosho = user_model.new(first_name: 'Tosho', age: 30).save
      pesho = user_model.new(first_name: 'Pesho', age: 20).save
      gosho = user_model.new(first_name: 'Gosho', age: 25).save

      actual = user_model.objects.order(age: :DESC).exec
      expect(actual == [tosho, gosho, pesho]).to be true
    end
  end

  describe 'filtering' do
    it 'filters by more than one atrribute' do
      tosho = user_model.new(first_name: 'Tosho', age: 30).save
      pesho = user_model.new(first_name: 'Pesho', age: 30).save
      gosho = user_model.new(first_name: 'Gosho', age: 25).save

      actual = user_model.objects.where(first_name: 'Pesho', age: 30).exec
      expect(actual).to eq [pesho]
    end

    it 'can filter with inequalities' do
      tosho = user_model.new(first_name: 'Tosho', age: 30).save
      pesho = user_model.new(first_name: 'Pesho', age: 20).save
      gosho = user_model.new(first_name: 'Gosho', age: 25).save

      actual = user_model.objects.where(age: "> 20")
      expect(actual).to match_array [tosho, gosho]

      actual = user_model.objects.where(age: ">= 20")
      expect(actual).to match_array [tosho, gosho, pesho]

      actual = user_model.objects.where(age: "< 30")
      expect(actual).to match_array [gosho, pesho]

      actual = user_model.objects.where(age: "!= 25")
      expect(actual).to match_array [tosho, pesho]
    end
  end

  it 'limits the results to the given number' do
    tosho = user_model.new(first_name: 'Tosho', age: 30).save
    pesho = user_model.new(first_name: 'Pesho', age: 20).save
    gosho = user_model.new(first_name: 'Gosho', age: 25).save

    actual = user_model.objects.limit(2).all.exec
    expect(actual.length).to be 2
  end

  it 'does not break if limit is bigger' do
    tosho = user_model.new(first_name: 'Tosho', age: 30).save
    pesho = user_model.new(first_name: 'Pesho', age: 20).save
    gosho = user_model.new(first_name: 'Gosho', age: 25).save

    actual = user_model.objects.limit(5).all.exec
    expect(actual.length).to be 3
  end

  it 'skips the given number of results in #offset' do
    tosho = user_model.new(first_name: 'Tosho', age: 30).save
    pesho = user_model.new(first_name: 'Pesho', age: 20).save
    gosho = user_model.new(first_name: 'Gosho', age: 25).save

    actual = user_model.objects.offset(2).all.exec
    expect(actual.length).to be 1
    expect(actual.first).to eq gosho
  end

  describe 'chaining' do
    it 'can chain where and order' do
      tosho = user_model.new(first_name: 'Tosho', age: 30).save
      pesho = user_model.new(first_name: 'Pesho', age: 20).save
      gosho = user_model.new(first_name: 'Gosho', age: 25).save

      actual = user_model.objects.where(age: "> 20").order(age: :ASC).exec
      expect(actual == [gosho, tosho]).to be true
    end

    it 'can chain where, order, limit and offset' do
      tosho = user_model.new(first_name: 'Tosho', age: 30).save
      pesho = user_model.new(first_name: 'Pesho', age: 20).save
      gosho = user_model.new(first_name: 'Gosho', age: 25).save
      ivan = user_model.new(first_name: 'Ivan', age: 35).save
      user_model.new(first_name: 'Dragan', age: 15).save

      actual = user_model.objects
                .where(age: "> 17")
                .order(first_name: :ASC)
                .limit(2)
                .offset(1)
                .exec

      expect(actual == [ivan, pesho]).to be true
    end
  end

  describe 'aggregations' do
    it 'counts by the given field' do
      tosho = user_model.new(first_name: 'Tosho', age: 30).save
      pesho = user_model.new(first_name: 'Pesho', age: 20).save
      gosho = user_model.new(first_name: 'Gosho').save

      expect(user_model.objects.count(:age)).to eq 2
    end

    it 'counts by all fields when given no argument' do
      tosho = user_model.new(first_name: 'Tosho', age: 30).save
      gosho = user_model.new(first_name: 'Gosho').save

      expect(user_model.objects.count).to eq 2
    end

    it 'finds average by given field' do
      gosho = user_model.new(first_name: 'Gosho', age: 52).save
      tosho = user_model.new(first_name: 'Tosho', age: 30).save
      gosho = user_model.new(first_name: 'Gosho', age: 40).save

      expect(user_model.objects.avg(:age)).to be_within(0.001).of (52 + 30 + 40.0)/3
    end

    it 'sums by the given field' do
      gosho = user_model.new(first_name: 'Gosho', age: 52).save
      tosho = user_model.new(first_name: 'Tosho', age: 30).save
      gosho = user_model.new(first_name: 'Gosho', age: 40).save

      expect(user_model.objects.sum(:age)).to be (30 + 40 + 52)
    end
  end

  describe 'associations' do
    describe '#has_one' do
      before(:all) do
        address_model = Class.new do
          include EasyMapper::Model

          attributes :city, :street
          table_name "address"
        end

        @employee_model = Class.new do
          include EasyMapper::Model

          attributes :name
          has_one :address, cls: address_model
          table_name "employee"
        end

        @address_model = address_model
      end

      before(:each) do
        @employee_model.objects.delete_all
        @address_model.objects.delete_all
      end

      it 'saves the associated objects when the owner is saved' do
        address = @address_model.new(city: 'Sofia', street: 'Notreal Str.')
        employee = @employee_model.new(name: 'pesho', address: address)
        employee.save

        expect(@address_model.objects.first).to eq employee.address
      end

      it 'updates the id column of the owned model' do
        address = @address_model.new(city: 'Sofia', street: 'Notreal Str.')
        employee = @employee_model.new(name: 'pesho', address: address)
        employee.save

        expect(address.id).not_to be_nil
      end

      it 'instantiates the associated objects after find' do
        address = @address_model.new(city: 'Sofia', street: 'Notreal Str.')
        employee = @employee_model.new(name: 'pesho', address: address)
        employee.save

        found_emp = @employee_model.find_by_name('pesho').first
        expect(found_emp.address).to eq address
      end
    end

    describe '#has_many' do
      before(:all) do
        @phone_entry = Class.new do
          include EasyMapper::Model

          attributes :name, :phone
          table_name "phone_entry"
        end

        @phone_book = Class.new do
          include EasyMapper::Model

          attributes :country
          has_many :phone_entries, cls: @phone_entry, mapped_by: :phone_book_id
          table_name "phone_book"
        end
      end

      before(:each) do
        @phone_entry.objects.delete_all
        @phone_book.objects.delete_all
      end

      it 'saves the associated objects when the owner is saved' do
        gosho = @phone_entry.new(name: 'Gosho', phone: '0885857378')
        pesho = @phone_entry.new(name: 'Pesho', phone: '0874537563')
        book = @phone_book.new(
          county: 'Bulgaria',
          phone_entries: [gosho, pesho]
        ).save

        expect(@phone_entry.objects).to match_array [pesho, gosho]
      end

      it 'instantiates the associated objects on find' do
        gosho = @phone_entry.new(name: 'Gosho', phone: '0885857378')
        pesho = @phone_entry.new(name: 'Pesho', phone: '0874537563')
        id = @phone_book.new(
          county: 'Bulgaria',
          phone_entries: [gosho, pesho]
        ).save.id

        result = @phone_book.find_by_id(id).first
        expect(result.phone_entries).to match_array [pesho, gosho]
      end
    end
  end
end


















