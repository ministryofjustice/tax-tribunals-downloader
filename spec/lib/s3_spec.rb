require 'spec_helper'

RSpec.describe TaxTribunal::S3 do
  let(:object) do
    Class.new do
      include TaxTribunal::S3
    end.new
  end

  let(:aws_resource) do
    instance_double(Aws::S3::Resource)
  end

  it 'creates a new resource' do
    expect(Aws::S3::Resource).to receive(:new)
    object.s3
  end

  it 'fetches credentails from ENV' do
    expect(ENV).
      to receive(:fetch).
      with('AWS_REGION', 'eu-west-1').
      and_return('eu-west-1')

    object.s3
  end

  it 'fetches the bucket name from ENV' do
    expect(ENV).to receive(:fetch).with('BUCKET_NAME')

    object.bucket_name
  end

  it 'exposes the bucket' do
    allow(ENV).to receive(:fetch).with('BUCKET_NAME').and_return('bob')
    expect(object).to receive(:s3).and_return(aws_resource)
    expect(aws_resource).to receive(:bucket).with('bob')

    object.bucket
  end
end
