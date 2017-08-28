require 'spec_helper'

RSpec.describe 'EasyMapper::Model' do
  let(:user_model) do
    Class.new do
      include EasyMapper::Model

      attributes :first_name, :last_name, :age
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

  it 'has find_by methods' do
    record = user_model.new(first_name: 'Ivan', last_name: 'Ivanov')

    expect(user_model).to respond_to(:find_by_id).with(1).arguments
    expect(user_model).to respond_to(:find_by_first_name).with(1).arguments
    expect(user_model).to respond_to(:find_by_last_name).with(1).arguments
    expect(user_model).to respond_to(:find_by_age).with(1).arguments
  end
end
