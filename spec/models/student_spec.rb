require 'rails_helper'

RSpec.describe Student, type: :model do
  let(:user) { User.new } 
  subject { described_class.new(name: "RAM", subject: "PHYSICS", marks: 85, user: user) }

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

  it 'is not valid without a name' do
    subject.name = nil
    expect(subject).to_not be_valid
    expect(subject.errors[:name]).to include("can't be blank")
  end

  it 'is not valid without a subject' do
    subject.subject = nil
    expect(subject).to_not be_valid
    expect(subject.errors[:subject]).to include("can't be blank")
  end

  it 'is not valid if marks are outside the range' do
    subject.marks = 150
    expect(subject).to_not be_valid
    expect(subject.errors[:marks]).to include("must be less than or equal to 100") 
  end

  it 'is valid if marks are within the range' do
    subject.marks = 100
    expect(subject).to be_valid
  end

  it 'is not valid if marks are below the minimum valid value' do
    subject.marks = -1
    expect(subject).to_not be_valid
    expect(subject.errors[:marks]).to include("must be greater than or equal to 0")
  end

  it 'is not valid if the name is too short' do
    subject.name = "AB"
    expect(subject).to_not be_valid
    expect(subject.errors[:name]).to include("is too short (minimum is 3 characters)")
  end
  
  it 'is not valid if the name is too long' do
    subject.name = "A" * 31
    expect(subject).to_not be_valid
    expect(subject.errors[:name]).to include("is too long (maximum is 30 characters)")
  end
  
  it 'is not valid if the subject is too short' do
    subject.subject = "AB"
    expect(subject).to_not be_valid
    expect(subject.errors[:subject]).to include("is too short (minimum is 3 characters)")
  end
  
  it 'is not valid if the subject is too long' do
    subject.subject = "A" * 21
    expect(subject).to_not be_valid
    expect(subject.errors[:subject]).to include("is too long (maximum is 20 characters)")
  end
  
end