module ActiveStorageHelpers
  def image_fixture_path(filename)
    Rails.root.join('spec', 'fixtures', 'files', filename)
  end
end

RSpec.configure do |config|
  config.include ActiveStorageHelpers
end
