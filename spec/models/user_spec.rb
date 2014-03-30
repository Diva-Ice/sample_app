require 'spec_helper'

describe User do

  before do
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar")
  end

  subject { @user } # субьект юзер

  it { should respond_to(:name) } # должен иметь Имя
  it { should respond_to(:email) } # должен иметь емэйл
  it { should respond_to(:password_digest) } # и т.д.
  it { should respond_to(:password) } 
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:admin) }
  it { should respond_to(:microposts) }
  it { should respond_to(:feed) }
  it { should respond_to(:relationships) }
  it { should respond_to(:followed_users) }
  it { should respond_to(:reverse_relationships) }
  it { should respond_to(:followers) }
  it { should respond_to(:following?) }
  it { should respond_to(:follow!) }
  it { should respond_to(:unfollow!) }

  it { should be_valid } # должен быть валидным
  it { should_not be_admin } # если не админ

  describe "with admin attribute set to 'true'" do # Описывает "атрибуты админа верны"
    before do
      @user.save!
      @user.toggle!(:admin) # "?пользователю присваиваются все атрибуты админа?"
    end

    it { should be_admin } # если админ
  end

  describe "when name is not present" do # Описывает "Когда имя пустое"
    before { @user.name = " " } # "если имя юзера отсутствует - не валидно"
    it { should_not be_valid }
  end
  describe "when email is not present" do # Описывает "Когда мыло пустое"
    before { @user.email = " " } # "если адрес отсутствует - не валидно"
    it { should_not be_valid }
  end
  describe "when name is too long" do # Описывает "если имя длинное"
    before { @user.name = "a" * 51 }
    it { should_not be_valid }# не валидно
  end

  describe "when email format is invalid" do # Описывает "если формат емэйла не соответствует правилу"
    it "should be invalid" do 
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        expect(@user).not_to be_valid
      end
    end
  end

  describe "when email format is valid" do # Описывает "если формат емэйла соответствует правилу"
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        expect(@user).to be_valid
      end
    end
  end
  describe "when email address is already taken" do # Описывает "Если емэйл был принят"
    before do
      user_with_same_email = @user.dup # ?
      user_with_same_email.email = @user.email.upcase # ?
      user_with_same_email.save # сохраняет юзера с данным емэйлом
    end

    it { should_not be_valid } # если не валидно
  end
  describe "when password is not present" do # Описывает "если пароль отсутствует"
    before do
      @user = User.new(name: "Example User", email: "user@example.com",
                       password: " ", password_confirmation: " ")
    end
    it { should_not be_valid }
  end

  describe "when password doesn't match confirmation" do # Описывает "Если пароль не совпадает с подтверждением"
    before { @user.password_confirmation = "mismatch" } # когда не совпадают пароль и подтверждение
    it { should_not be_valid }
  end
  describe "with a password that's too short" do # Описывает "Если пароль короткий"
    before { @user.password = @user.password_confirmation = "a" * 5 }
    it { should be_invalid }
  end

  describe "return value of authenticate method" do # Описывает "Возвращение значения аутентификации"
    before { @user.save } # сохраненный пользователь
    let(:found_user) { User.find_by(email: @user.email) } # ??? 

    describe "with valid password" do # Описывает "Валидный пароль"
      it { should eq found_user.authenticate(@user.password) } # ???
    end

    describe "with invalid password" do # Описывает "невалидный пароль"
      let(:user_for_invalid_password) { found_user.authenticate("invalid") } # ???

      it { should_not eq user_for_invalid_password } # ???
      specify { expect(user_for_invalid_password).to be_false } # ???
    end
  end
  describe "email address with mixed case" do # Описывает "набор емэйла в разном регистре"
    let(:mixed_case_email) { "Foo@ExAMPle.CoM" } # ???

    it "should be saved as all lower-case" do # Описывает "сохранение емэйла в нижнем регистре"
      @user.email = mixed_case_email # емэйл набран разным регистром 
      @user.save # сохранить пользователя
      expect(@user.reload.email).to eq mixed_case_email.downcase # перевести адрес в нижний регистр
    end
  end

  describe "remember token" do # описывает "Запоминание метки????"
    before { @user.save }
    its(:remember_token) { should_not be_blank } # ???
  end

  describe "micropost associations" do # описывает "Ассоциации микропостов"
    before { @user.save } #  сохраненный пользователь
    let!(:older_micropost) do # старые посты
      FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago) # имеют сам пост, принадлежность юзеру и сортируются в списке(ниже новых)
    end
    let!(:newer_micropost) do # новые посты
      FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago) # имеют сам пост, принадлежность юзеру и сортируются в списке(выше старых)
    end

    it "should have the right microposts in the right order" do  # описывает "Правильный порядок микропостов"      
      expect(@user.microposts.to_a).to eq [newer_micropost, older_micropost] #???
    end
    it "should destroy associated microposts" do # описывает "удаление микропостов"
      microposts = @user.microposts.to_a # пост принадлежит юзеру
      @user.destroy  # юзер удаляет пост
      expect(microposts).not_to be_empty #???
      microposts.each do |micropost| # ???
        expect(Micropost.where(id: micropost.id)).to be_empty # ???
      end
    end
    describe "status" do # ???? тут ваще ниче не понятно 
      let(:unfollowed_post) do
        FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
      end
      let(:followed_user) { FactoryGirl.create(:user) }

      before do
        @user.follow!(followed_user)
        3.times { followed_user.microposts.create!(content: "Lorem ipsum") }
      end

      its(:feed) { should include(newer_micropost) }
      its(:feed) { should include(older_micropost) }
      its(:feed) { should_not include(unfollowed_post) }
      its(:feed) do
        followed_user.microposts.each do |micropost|
          should include(micropost)
        end
      end
    end
  end

  describe "following" do
    let(:other_user) { FactoryGirl.create(:user) }
    before do
      @user.save
      @user.follow!(other_user)
    end

    it { should be_following(other_user) }
    its(:followed_users) { should include(other_user) }

    describe "followed user" do
      subject { other_user }
      its(:followers) { should include(@user) }
    end

    describe "and unfollowing" do
      before { @user.unfollow!(other_user) }

      it { should_not be_following(other_user) }
      its(:followed_users) { should_not include(other_user) }
    end
  end
end
