require "spec_helper"

RSpec.describe "EasyMapper::Model" do
  let(:user_model) do
    Class.new do
      include EasyMapper::Model

      attributes :first_name, :last_name, :age
    end
  end

  it 'creates attribute accessors' do
    record = user_model.new
    record.first_name = 'Pesho'
    record.last_name  = 'Petrov'

    expect(record.first_name).to eq 'Pesho'
    expect(record.last_name ).to eq 'Petrov'
  end

  it 'can be passed initial values to constructor' do
    user = user_model.new(
      first_name: 'Pesho',
      last_name: 'Petrov',
      age: 15)

    expect(user.first_name).to eq 'Pesho'
    expect(user.last_name ).to eq 'Petrov'
    expect(user.age).to eq 15
  end
end

