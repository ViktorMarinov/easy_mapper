require 'spec_helper'

require_relative 'utils/mock_repository'

RSpec.describe 'EasyMapper::Model' do
  let(:user_model) do
    Class.new do
      include EasyMapper::Model

      attributes :first_name, :last_name, :age
      repository MockRepository.new
    end
  end

  describe 'id' do
    it 'is auto added in the record' do
      record = user_model.new

      expect(record).to respond_to(:id)
    end

    it 'is nil if the record is not saved' do
      record = user_model.new

      expect(record.id).to be nil
    end

    it 'is not nil after the record is saved' do
      record = user_model.new
      record.save

      expect(record.id).not_to be nil
    end
  end

  it 'creates attribute accessors' do
    record = user_model.new
    record.first_name = 'Pesho'
    record.last_name  = 'Petrov'

    expect(record.first_name).to eq 'Pesho'
    expect(record.last_name).to eq 'Petrov'
  end

  it 'can be passed initial values to constructor' do
    user = user_model.new(
      first_name: 'Pesho',
      last_name: 'Petrov',
      age: 15
    )

    expect(user.first_name).to eq 'Pesho'
    expect(user.last_name).to eq 'Petrov'
    expect(user.age).to eq 15
  end

  it 'has #find_by methods' do
    record = user_model.new(first_name: 'Ivan', last_name: 'Ivanov')

    expect(user_model).to respond_to(:find_by_id).with(1).arguments
    expect(user_model).to respond_to(:find_by_first_name).with(1).arguments
    expect(user_model).to respond_to(:find_by_last_name).with(1).arguments
    expect(user_model).to respond_to(:find_by_age).with(1).arguments
  end

  it 'has #objects method for building queries' do
    expect(user_model).to respond_to(:objects).with(0).arguments
  end

  describe 'equality comparison' do
    it 'compares by id if both records are saved' do
      ivan = user_model.new(first_name: 'Ivan')
      ivan.save

      petar = user_model.new(first_name: 'Petar')
      petar.save

      expect(ivan).to_not eq petar
      expect(ivan).to eq ivan

      modified_ivan = user_model.objects.where(id: ivan.id).first
      modified_ivan.first_name = 'Gosho'

      expect(ivan).to eq modified_ivan
    end

    it 'uses #equal? if there are no ids' do
      first_user  = user_model.new(first_name: 'Ivan')
      second_user = user_model.new(first_name: 'Ivan')

      expect(first_user).to_not eq second_user
      expect(first_user).to eq first_user
    end
  end

  describe '#delete' do
    it 'deletes only the record for which it is called' do
      ivan = user_model.new(first_name: 'Ivan').save
      user_model.new(first_name: 'Petar').save
      user_model.new(first_name: 'Georgi').save

      ivan.delete

      # all_records = user_model.objects.where({}).map(&:first_name)
      # expect(all_records).to match_array ['Petar', 'Georgi']
    end

    it 'raises an error if the record is not saved' do
      expect { user_model.new(first_name: 'Ivan').delete }.to raise_error(
        EasyMapper::Errors::DeleteUnsavedRecordError
      )
    end
  end

  describe 'associations' do
    before(:each) do
      @address_model = Class.new do
        include EasyMapper::Model

        attributes :city, :street
      end

      @employee_model = Class.new do
        include EasyMapper::Model

        attributes :name
        has_one :address, cls: @address_model
        repository MockRepository.new
      end

      @address_book_model = Class.new do
        include EasyMapper::Model

        attributes :price
        has_many :addresses, cls: @address_model
      end
    end

    it 'creates attribute accessor for #has_one associations' do
      address = @address_model.new(city: 'Sofia', street: 'Notreal Str.')
      employee = @employee_model.new(name: 'pesho')
      employee.address = address

      expect(employee.address).to be address
    end

    it 'creates attribute accessor for #has_many associations' do
      address1 = @address_model.new(city: 'Sofia', street: 'Notreal Str.')
      address2 = @address_model.new(city: 'London', street: 'Real Str.')
      book = @address_book_model.new(price: 15)
      book.addresses = [address1, address2]

      expect(book.addresses).to match_array [address1, address2]
    end

    # it 'creates accessors for #belongs_to associations' do
    #   address1 = @address_model.new(city: 'Sofia', street: 'Notreal Str.')
    #   address2 = @address_model.new(city: 'London', street: 'Real Str.')
    #   book = @address_book_model.new(price: 15)
    #   book.addresses = [address1, address2]

    #   expect(book.addresses).to match_array [address1, address2]
    # end

    it 'can pass initial values for associations on init' do
      address1 = @address_model.new(city: 'Sofia', street: 'Notreal Str.')
      address2 = @address_model.new(city: 'London', street: 'Real Str.')
      book = @address_book_model.new(
        price: 15,
        addresses: [address1, address2])

      expect(book.addresses).to match_array [address1, address2]
    end

    it 'initializes has_many attribute with empty list' do
      book = @address_book_model.new(price: 15)

      expect(book.addresses).to be_empty
    end
  end
end
