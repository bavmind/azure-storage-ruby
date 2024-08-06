#-------------------------------------------------------------------------
# # Copyright (c) Microsoft and contributors. All rights reserved.
#
# The MIT License(MIT)

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files(the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and / or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions :

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#--------------------------------------------------------------------------
require "integration/test_helper"

describe Azure::Storage::File::FileService do
  let(:user_agent_prefix) { "azure_storage_ruby_integration_test" }
  subject {
    Azure::Storage::File::FileService.create(SERVICE_CREATE_OPTIONS()) { |headers|
      headers["User-Agent"] = "#{user_agent_prefix}; #{headers['User-Agent']}"
    }
  }
  after { ShareNameHelper.clean }

  describe "#set/get_directory_metadata" do
    let(:share_name) { ShareNameHelper.name }
    let(:directory_name) { FileNameHelper.name }
    let(:metadata) { {"CustomMetadataProperty" => "CustomMetadataValue"} }
    before {
      subject.create_share share_name
      subject.create_directory share_name, directory_name
    }

    it "sets and gets custom metadata for the directory" do
      result = subject.set_directory_metadata share_name, directory_name, metadata
      _(result).must_be_nil
      directory = subject.get_directory_metadata share_name, directory_name
      _(directory).wont_be_nil
      _(directory.name).must_equal directory_name
      metadata.each { |k, v|
        _(directory.metadata).must_include k.downcase
        _(directory.metadata[k.downcase]).must_equal v
      }
    end

    it "errors if the directory does not exist" do
      assert_raises(Azure::Core::Http::HTTPError) do
        subject.get_directory_metadata share_name, FileNameHelper.name
      end
      assert_raises(Azure::Core::Http::HTTPError) do
        subject.set_directory_metadata share_name, FileNameHelper.name, metadata
      end
    end
  end
end
