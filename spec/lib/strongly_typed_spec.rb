require 'spec_helper'
require File.join(GemRoot, 'lib', 'strongly_typed')
require 'date'

describe StronglyTyped do

  describe '#validate_type_equals' do
    let(:name) { 'parameter' }
    subject { StronglyTyped.validate_type_equals(name, parameter, type) }

    context 'when type matches' do
      let(:parameter) { Customer.new }
      let(:type) { Customer }
      specify{ expect(subject).to be_truthy }
    end

    context "when type doesn't match" do
      let(:parameter) { double }
      let(:type) { Customer }
      specify{ expect{ subject }.to raise_error(ArgumentError) }

      specify 'error message' do
        begin; subject; rescue ArgumentError => e
          expect(e.message).to eq("parameter must be a Customer")
        end
      end

    end
  end

  describe '#validate_array_of_type' do
    let(:type) { Date }
    let(:name) { 'parameter' }
    subject { StronglyTyped.validate_array_of_type(name, parameter, type) }

    context 'when parameter is not an array' do
      let(:parameter) { Date.new(2014, 11, 11) }
      specify 'error message' do
        begin; subject; rescue ArgumentError => e
          expect(e.message).to eq('parameter must be an array of Dates')
        end
      end
    end

    context 'when type matches' do
      let(:parameter) { 3.times.collect { Date.new(2014, 11, 11) } }
      specify{ expect(subject).to be_truthy }
    end

    context "when type doesn't match" do
      let(:parameter) { [Date.new(2014, 11, 11), double] }
      specify{ expect{ subject }.to raise_error(ArgumentError) }

      specify 'error message' do
        begin; subject; rescue ArgumentError => e
          expect(e.message).to eq('parameter must be an array of Dates')
        end
      end
    end
  end

  describe '#validate_type_in' do
    let(:types) { [Customer, CustomerJob] }
    let(:name) { 'parameter' }
    subject { StronglyTyped.validate_type_in(name, parameter, types) }

    context 'when type matches' do
      let(:parameter) { Customer.new }
      specify{ expect(subject).to be_truthy }
    end

    context "when type doesn't match" do
      let(:parameter) { double }
      specify{ expect{ subject }.to raise_error(ArgumentError) }

      specify 'error message' do
        begin; subject; rescue ArgumentError => e
          expect(e.message).to eq('parameter must be one of: ["Customer", "CustomerJob"]')
        end
      end

    end
  end

  describe '#validate_value_greater_than' do
    let(:name) { 'sentinel' }
    let(:compared_with) { Date.new(2014, 11, 11) }
    subject { StronglyTyped.validate_value_greater_than(name, parameter, compared_with) }

    context 'when value is less than' do
      let(:parameter) { Date.new(2014, 10, 31) }
      specify { expect{ subject }.to raise_error(ArgumentError) }

      specify 'error message' do
        begin; subject; rescue ArgumentError => e
          expect(e.message).to eq("sentinel must be greater than #{compared_with}")
        end
      end
    end

    context 'when value is greater than' do
      let(:parameter) { Date.new(2014, 11, 15) }
      specify{ expect(subject).to be_truthy }
    end
  end

  describe '#validate_value_in' do
    context 'when not given the right parameters' do
      let(:name) { 'exceptional' }
      let(:parameter) { 'that is rather exceptional!' }
      subject { StronglyTyped.validate_value_in(name, parameter, face: 'plant') }
      specify{ expect{ subject }.to raise_error(ArgumentError) }

      specify 'error message' do
        begin; subject; rescue ArgumentError => e
          expect(e.message).to eq('args must include either :options, or both: [:first, :last]')
        end
      end
    end

    context 'when given an explicit set of values' do
      let(:name)  { 'method_of_propulsion' }
      let(:options) { [:run, :walk, :saunter, :jog] }
      subject { StronglyTyped.validate_value_in(name, parameter, options: options) }

      context 'when parameter is not in the set' do
        let(:parameter) { :swim }
        specify{ expect{ subject }.to raise_error(ArgumentError) }

        specify 'error message' do
          begin; subject; rescue ArgumentError => e
            expect(e.message).to eq("method_of_propulsion must have a value equal to one of: [:run, :walk, :saunter, :jog] - received: swim")
          end
        end
      end

      context 'when parameter is in the set' do
        let(:parameter) { :jog }
        specify{ expect(subject).to be_truthy }
      end
    end

    context 'when given a range of values' do
      let(:name)  { 'pounds_lifted' }
      let(:first) { 1 }
      let(:last)  { 10 }
      subject { StronglyTyped.validate_value_in(name, parameter, first: first, last: last) }

      context 'when parameter is less than the range' do
        let(:parameter) { -1 }
        specify{ expect{ subject }.to raise_error(ArgumentError) }

        specify 'error message' do
          begin; subject; rescue ArgumentError => e
            expect(e.message).to eq("pounds_lifted must have a value in the range: [1..10]")
          end
        end
      end

      context 'when parameter is greater than the range' do
        let(:parameter) { 11 }
        specify{ expect{ subject }.to raise_error(ArgumentError) }

        specify 'error message' do
          begin; subject; rescue ArgumentError => e
            expect(e.message).to eq('pounds_lifted must have a value in the range: [1..10]')
          end
        end
      end

      context 'when parameter is in the range' do
        let(:parameter) { 7 }
        specify{ expect(subject).to be_truthy }
      end
    end
  end

end
