require "spec_helper"
require 'configuration'

module JDict
  describe Configuration do
    describe "#debug" do
      it "default value is false" do
        Configuration.new.debug = false
      end
    end

    describe "#debug=" do
      it "can set value" do
        config = Configuration.new
        config.debug = true
        expect(config.debug).to eq(true)
      end
    end
  end
end
