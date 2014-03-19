require 'spec_helper'

describe NetSuite::Records::ServiceSaleItem do
  let(:item) { NetSuite::Records::ServiceSaleItem.new }

  it 'has the right fields' do
    [
      :available_to_partners, :cost_estimate, :cost_estimate_type, :cost_estimate_units, :create_job, :created_date,
      :display_name, :dont_show_price, :enforce_min_qty_internally, :exclude_from_sitemap, :featured_description,
      :include_children, :is_donation_item, :is_fulfillable, :is_gco_compliant, :is_inactive, :is_online, :is_taxable,
      :item_id, :last_modified_date, :matrix_option_list, :matrix_type, :max_donation_amount, :meta_tag_html,
      :minimum_quantity, :minimum_quantity_units, :no_price_message, :offer_support, :on_special, :out_of_stock_behavior,
      :out_of_stock_message, :overall_quantity_pricing_type, :page_title, :presentation_item_list, :prices_include_tax,
      :rate, :related_items_description, :sales_description, :search_keywords,
      :show_default_donation_amount, :site_category_list, :sitemap_priority, :soft_descriptor, :specials_description,
      :store_description, :store_detailed_description, :store_display_name, :translations_list, :upc_code, :url_component,
      :use_marginal_rates, :vsoe_deferral, :vsoe_delivered, :vsoe_permit_discount, :vsoe_price, :vsoe_sop_group
    ].each do |field|
      item.should have_field(field)
    end

    # TODO there is a probably a more robust way to test this
    item.custom_field_list.class.should == NetSuite::Records::CustomFieldList
    item.pricing_matrix.class.should == NetSuite::Records::PricingMatrix
  end

  it 'has the right record_refs' do
    [
      :billing_schedule, :cost_category, :custom_form, :deferred_revenue_account, :department, :income_account,
      :issue_product, :item_options_list, :klass, :location, :parent, :pricing_group, :purchase_tax_code,
      :quantity_pricing_schedule, :rev_rec_schedule, :sale_unit, :sales_tax_code, :store_display_image,
      :store_display_thumbnail, :store_item_template, :subsidiary_list, :tax_schedule, :units_type
    ].each do |record_ref|
      item.should have_record_ref(record_ref)
    end
  end

  describe '.get' do
    context 'when the response is successful' do
      let(:response) { NetSuite::Response.new(:success => true, :body => { :item_id => 'penguins' }) }

      it 'returns a ServiceSaleItem instance populated with the data from the response object' do
        NetSuite::Actions::Get.should_receive(:call).with(NetSuite::Records::ServiceSaleItem, :external_id => 20).and_return(response)
        customer = NetSuite::Records::ServiceSaleItem.get(:external_id => 20)
        customer.should be_kind_of(NetSuite::Records::ServiceSaleItem)
        customer.item_id.should eql('penguins')
      end
    end

    context 'when the response is unsuccessful' do
      let(:response) { NetSuite::Response.new(:success => false, :body => {}) }

      it 'raises a RecordNotFound exception' do
        NetSuite::Actions::Get.should_receive(:call).with(NetSuite::Records::ServiceSaleItem, :external_id => 20).and_return(response)
        lambda {
          NetSuite::Records::ServiceSaleItem.get(:external_id => 20)
        }.should raise_error(NetSuite::RecordNotFound,
          /NetSuite::Records::ServiceSaleItem with OPTIONS=(.*) could not be found/)
      end
    end
  end

  describe '#add' do
    # let(:item) { NetSuite::Records::ServiceSaleItem.new(:cost => 100, :is_inactive => false) }

    context 'when the response is successful' do
      let(:response) { NetSuite::Response.new(:success => true, :body => { :internal_id => '1' }) }

      it 'returns true' do
        NetSuite::Actions::Add.should_receive(:call).
            with(item).
            and_return(response)
        item.add.should be_true
      end
    end

    context 'when the response is unsuccessful' do
      let(:response) { NetSuite::Response.new(:success => false, :body => {}) }

      it 'returns false' do
        NetSuite::Actions::Add.should_receive(:call).
            with(item).
            and_return(response)
        item.add.should be_false
      end
    end
  end

  describe '#delete' do
    context 'when the response is successful' do
      let(:response) { NetSuite::Response.new(:success => true, :body => { :internal_id => '1' }) }

      it 'returns true' do
        NetSuite::Actions::Delete.should_receive(:call).
            with(item).
            and_return(response)
        item.delete.should be_true
      end
    end

    context 'when the response is unsuccessful' do
      let(:response) { NetSuite::Response.new(:success => false, :body => {}) }

      it 'returns false' do
        NetSuite::Actions::Delete.should_receive(:call).
            with(item).
            and_return(response)
        item.delete.should be_false
      end
    end
  end

  describe '#to_record' do
    before do
      item.item_id = 'penguins'
      item.is_online     = true
    end

    it 'can represent itself as a SOAP record' do
      record = {
        'listAcct:itemId' => 'penguins',
        'listAcct:isOnline'     => true
      }
      item.to_record.should eql(record)
    end
  end

  describe '#record_type' do
    it 'returns a string of the SOAP type' do
      item.record_type.should eql('listAcct:ServiceSaleItem')
    end
  end

end
