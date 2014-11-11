require 'spec_helper'
require 'json'

describe Fidor::Permission do

  let(:readwrite_transfer) {
    Fidor::Acl.init
    Fidor::Acl['readwrite_sepa_credit_transfer']
  }
  let(:permission) { Fidor::Permission.from_hash readwrite_transfer }

  describe '.from_hash' do
    it 'includes the acls values' do
      expect(permission.name).to eq 'readwrite_sepa_credit_transfer'

      ['context', 'privileges', 'fields_r', 'fields_rw'].each do |field|
        expect(permission.send(field)).to eq readwrite_transfer[field]
      end
    end
  end

  describe '#to_json' do
    subject { JSON.parse permission.to_json }

    let(:expectation) { { 'name' => 'readwrite_transfer' }.merge readwrite_transfer }

    it { should eql expectation }
  end

  describe 'translation' do
    describe '#translated_name' do
      subject { permission.translated_name }

      it { should eq I18n.t('permission_names.readwrite_sepa_credit_transfer') }
    end

    describe '#translated_info' do
      subject { permission.translated_info }

      it { should eq I18n.t('permission_names.readwrite_sepa_credit_transfer_info') }

      it 'be nil if translation is missing' do
        p = Fidor::Permission.from_hash(Fidor::Acl['read_account_full'])
        expect(p.translated_info).to eq nil
      end
    end

    describe '#translated_fields_r' do
      subject { permission.translated_fields_r }

      it { should include 'Created at' }
    end
    describe '#translated_fields_rw' do
      subject { permission.translated_fields_rw }

      it { should include 'Amount' }
    end
  end

  describe '#fields_r' do
    subject { permission.fields_r }

    let(:permission) { Fidor::Permission.new }


    context 'with an undefined value' do

      it { should eql [] }
    end

    context 'with ["bar"] as value' do
      before { permission.fields_r = ['bar'] }

      it { should eql ['bar'] }
    end
  end

  describe '#privileges' do
    subject { permission.privileges }

    let(:permission) { Fidor::Permission.new }


    context 'with an undefined value' do

      it { should eql [] }
    end

    context 'with ["bar"] as value' do
      before { permission.privileges = ['bar'] }

      it { should eql ['bar'] }
    end
  end

  describe '.==' do
    let(:one) { Fidor::Permission.new }
    let(:two) { Fidor::Permission.new }
    subject { one == two }

    context 'with two new instances' do
      it { should be true }
    end

    context 'name' do
      context 'with different names' do
        before do
          one.name = 'Foo'
          two.name = 'Bar'
        end

        it { should be false }
      end

      context 'with same names' do
        before do
          one.name = 'Foo'
          two.name = 'Foo'
        end

        it { should be true }
      end
    end

    context 'fields' do
      context 'with same fields in different order' do
        before do
          one.fields_r = ['Foo', 'Bar', 'Baz']
          two.fields_r = ['Bar', 'Foo', 'Baz']
        end

        it { should be true }
      end

      context 'with different fields' do
        before do
          one.fields_rw = ['Foo', 'Bar', 'Baz']
          two.fields_rw = ['Bar', 'ZAP', 'Baz']
        end

        it { should be false }
      end
    end

    context 'privileges' do
      context 'with same privileges in different order' do
        before do
          one.privileges = ['Foo', 'Bar', 'Baz']
          two.privileges = ['Bar', 'Foo', 'Baz']
        end

        it { should be true }
      end

      context 'with different privileges' do
        before do
          one.privileges = ['Foo', 'Bar', 'Baz']
          two.privileges = ['Bar', 'ZAP', 'Baz']
        end

        it { should be false }
      end
    end

  end

end