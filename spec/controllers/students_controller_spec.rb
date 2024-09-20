require 'rails_helper'

RSpec.describe StudentsController, type: :controller do
  let(:user) { User.create(email: "test@example.com", password: "password") }
  let(:student) { Student.create(name: "TEST STUDENT", subject: "MATH", marks: 85, user_id: user.id) }

  before do
    sign_in user
  end

  describe "GET #index" do
    it "returns a success response" do
      student
      get :index
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      it "creates a new Student" do
        post :create, params: { student: { name: "PARIJAT", subject: "HIST", marks: 72, user_id: user.id } }
        expect(response).to have_http_status(200)
        json_response = JSON.parse(response.body)
        expect(json_response["success"]).to be_truthy
        expect(json_response["message"]).to eq("Student successfully created or updated!")
      end
    end

    context "with invalid parameters" do
      it "does not create a student with blank name and subject" do
        post :create, params: { student: { name: "", subject: "", marks: nil, user_id: user.id } }
        expect(response).to have_http_status(422)
        json_response = JSON.parse(response.body)
        expect(json_response["success"]).to be_falsey
        expect(json_response["errors"]).to include("Name can't be blank", "Subject can't be blank")
      end
    end
  end

  describe "PATCH #update" do
    context "with valid parameters" do
      it "updates the student" do
        patch :update, params: { id: student.id, student: { name: "UPDATED NAME", subject: "UPDATED SUBJECT", marks: 90 } }
        student.reload
        expect(student.name).to eq("UPDATED NAME")
        expect(student.subject).to eq("UPDATED SUBJECT")
        expect(student.marks).to eq(90)
        expect(response).to have_http_status(200)
        json_response = JSON.parse(response.body)
        expect(json_response["success"]).to be_truthy
        expect(json_response["message"]).to eq("Student successfully updated!")
      end
    end

    context "with invalid parameters" do
      it "does not update the student with blank name" do
        patch :update, params: { id: student.id, student: { name: "", subject: "UPDATED SUBJECT", marks: 90 } }
        expect(response).to have_http_status(422)
        json_response = JSON.parse(response.body)
        expect(json_response["success"]).to be_falsey
        expect(json_response["errors"]).to include("Name can't be blank")
      end
    end
  end

  describe "DELETE #delete_student" do
    it "deletes the student and returns a success response" do
      student
      expect {
        delete :delete_student, params: { ids: [student.id] }, format: :json
      }.to change(Student, :count).by(-1)
      expect(response).to have_http_status(:success)
    end

    it "returns a not found response when the student does not exist" do
      expect {
        delete :delete_student, params: { ids: [-1] }, format: :json
      }.to_not change(Student, :count)
      expect(response).to have_http_status(:not_found)
    end
  end
end