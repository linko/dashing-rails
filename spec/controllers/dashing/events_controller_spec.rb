require 'spec_helper'

describe Dashing::EventsController do

  describe 'GET "index"' do

    def action
      get :index, use_route: :dashing
    end

    pending 'Require multithreads spec'

    context 'should use redis instanse from config' do
      before { ::Redis.any_instance.stub(:psubscribe).and_raise IOError }

      context 'when defaut redis connection' do
        before { Dashing.configure {|config|} }

        it 'should use just new instance' do
          action()
          expect(response).to be_success
          expect(assigns(:redis)).to be_a_kind_of(Redis)
        end
      end

      context 'when custom redis connection is configured' do
        let(:redis_connection) { double(Redis, redis_namespace: 'test') }

        before { redis_connection.should_receive(:quit) }
        before { redis_connection.should_receive(:psubscribe).and_raise(IOError) }

        before { Dashing.configure { |config| config.redis = redis_connection } }

        it 'should use custom connection' do
          action()
          expect(response).to be_success
          expect(assigns(:redis)).to eq redis_connection
        end

        # return back for next specs, otherwise causes random fails
        after { Dashing.configure { |config| config.redis = ::Redis.new } }
      end
    end

  end
end
