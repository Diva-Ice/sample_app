require 'spec_helper'

describe Micropost do

  let(:user) { FactoryGirl.create(:user) } # тащит все данные юзера
  before { @micropost = user.microposts.build(content: "Lorem ipsum") } # ???

  subject { @micropost }

  it { should respond_to(:content) } # имеет сам контент
  it { should respond_to(:user_id) } # имеет идентификатор юзера
  it { should respond_to(:user) } # имеет данные юзера
  its(:user) { should eq user } # ???

  it { should be_valid } # валидно

  describe "when user_id is not present" do # описывает "Если ID юзера нет"
    before { @micropost.user_id = nil }
    it { should_not be_valid } # не валидно
  end

  describe "with blank content" do # описывает "Пустое поле сообщения"
    before { @micropost.content = " " } # поле пустое
    it { should_not be_valid } # не валидно
  end

  describe "with content that is too long" do # описывает "Длинное сообщение"
    before { @micropost.content = "a" * 141 } # текст длиннее 140 символов
    it { should_not be_valid } # не валидно
  end
end