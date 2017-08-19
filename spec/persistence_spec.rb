require "spec_helper"

RSpec.describe "EasyMapper::Model" do
  let(:model) do
    Class.new do
      include EasyMapper::Model::Persistence

    end
  end
end

