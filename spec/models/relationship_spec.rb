require 'spec_helper'

describe Relationship do # описание связей

  let(:follower) { FactoryGirl.create(:user) } # подписанные юзеры подтягивают данные о юзерах
  let(:followed) { FactoryGirl.create(:user) } # юзеры, на которых подписан пользователь подтягивают данные о себе
  let(:relationship) { follower.relationships.build(followed_id: followed.id) } # не понятно

  subject { relationship } # субьект Связи

  it { should be_valid } # валидно

  describe "follower methods" do # описание "Методы фолловер"
    it { should respond_to(:follower) } # должно реагировать на фолловер
    it { should respond_to(:followed) } # должно реагировать на фолловед
    its(:follower) { should eq follower } #  вытягивает данные подписанных пользователей из подписанных
    its(:followed) { should eq followed } # аналогично предыдущей строке
  end

  describe "when followed id is not present" do # описание "Когда нет ID фолловера"
    before { relationship.followed_id = nil }
    it { should_not be_valid } # не валидно
  end

  describe "when follower id is not present" do # аналогично
    before { relationship.follower_id = nil }
    it { should_not be_valid }
  end
end
