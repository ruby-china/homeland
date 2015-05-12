require 'rails_helper'

describe "API V3", "replies", :type => :request do
  let!(:reply) { Factory(:reply, user: current_user) }
  
  describe "GET /api/v3/replies/:id.json" do  
    it "should be ok" do
      get "/api/v3/replies/#{reply.id}.json"
      expect(response.status).to eq(200)
      expect(json["reply"]).to include(*%W(id topic_id user body body_html))
      expect(json["reply"]["id"]).to eq reply.id
      expect(json["reply"]["body"]).to eq reply.body
    end
  end
  
  describe 'POST /api/v3/replies/:id.json' do
    it 'require login' do
      post "/api/v3/replies/#{reply.id}.json", body: "bar dar"
      expect(response.status).to eq(401)
    end
    
    it 'require owner' do
      r = Factory(:reply)
      login_user!
      post "/api/v3/replies/#{r.id}.json", body: "bar dar"
      expect(response.status).to eq(403)
    end
    
    it "should work by owner" do
      login_user!
      post "/api/v3/replies/#{reply.id}.json", body: "bar dar"
      expect(response.status).to eq(201)
      reply.reload
      expect(reply.body).to eq "bar dar"
      expect(reply.body_html).to eq "<p>bar dar</p>"
    end
    
    it 'should work by admin' do
      login_user!
      allow_any_instance_of(User).to receive(:admin?).and_return(true)
      r = Factory(:reply)
      post "/api/v3/replies/#{r.id}.json", body: "bar dar"
      expect(response.status).to eq(201)
    end
  end
  
  describe 'DELETE /api/v3/replies/:id.json' do
    it 'require login' do
      delete "/api/v3/replies/#{reply.id}.json"
      expect(response.status).to eq(401)
    end
    
    it 'require owner' do
      r = Factory(:reply)
      login_user!
      delete "/api/v3/replies/#{r.id}.json"
      expect(response.status).to eq(403)
    end
    
    it "should work by owner" do
      login_user!
      delete "/api/v3/replies/#{reply.id}.json"
      expect(response.status).to eq(200)
      reply.reload
      expect(reply.deleted_at).not_to eq nil
    end
    
    it 'should work by admin' do
      login_user!
      allow_any_instance_of(User).to receive(:admin?).and_return(true)
      r = Factory(:reply)
      delete "/api/v3/replies/#{r.id}.json"
      expect(response.status).to eq(200)
      r.reload
      expect(r.deleted_at).not_to eq nil
    end
  end
end