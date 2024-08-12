#-------------------------------------------------------------------------
# # Copyright (c) Microsoft and contributors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#--------------------------------------------------------------------------
require "test_helper"
require "azure/core"

describe "Azure core service" do
  subject do
    Azure::Core::Service.new
  end

  it "generate_uri should return URI instance" do
    subject.host = "http://dumyhost.uri"
    _(subject.generate_uri).must_be_kind_of ::URI
    _(subject.generate_uri.to_s).must_equal "http://dumyhost.uri/"
  end

  it "generate_uri should add path to the url" do
    _(subject.generate_uri("resource/entity/").path).must_equal "/resource/entity/"
  end

  it "generate_uri should correctly join the path if host url contained a path" do
    subject.host = "http://dummy.uri/host/path"
    _(subject.generate_uri("resource/entity/").path).must_equal "/host/path/resource/entity/"
  end

  it "generate_uri should encode the keys" do
    _(subject.generate_uri("", {"key !" => "value"}).query).must_include "key+%21=value"
  end

  it "generate_uri should encode the values" do
    _(subject.generate_uri("", {"key" => "value !"}).query).must_include "key=value+%21"
  end

  it "generate_uri should set query string to the encoded result" do
    _(subject.generate_uri("", {"key" => "value !", "key !" => "value"}).query).must_equal "key=value+%21&key+%21=value"
  end

  it "generate_uri should override the default timeout" do
    _(subject.generate_uri("", {"timeout" => 45}).query).must_equal "timeout=45"
  end

  it "generate_uri should not include any query parameters" do
    _(subject.generate_uri("", nil).query).must_be_nil
  end

  it "generate_uri should not re-encode path with spaces" do
    subject.host = "http://dumyhost.uri"
    encoded_path = "blob%20name%20with%20spaces"
    uri = subject.generate_uri(encoded_path, nil)
    _(uri.host).must_equal "dumyhost.uri"
    _(uri.path).must_equal "/blob%20name%20with%20spaces"
  end

  it "generate_uri should not re-encode path with special characters" do
    subject.host = "http://dumyhost.uri"
    encoded_path = "host/path/%D1%84%D0%B1%D0%B0%D1%84.jpg"
    uri = subject.generate_uri(encoded_path, nil)
    _(uri.host).must_equal "dumyhost.uri"
    _(uri.path).must_equal "/host/path/%D1%84%D0%B1%D0%B0%D1%84.jpg"
  end
end
