module Fixtures
  def fixture_file(filename)
    File.read(File.join(File.dirname(__FILE__), "fixtures", filename))
  end
end
