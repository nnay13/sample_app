# == Schema Information
# Schema version: 20110720092245
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(255)
#  salt               :string(255)
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#

require 'spec_helper'

describe User do
  before(:each) do
    @attr = { :name => "Titi TOTO", 
              :email=>"titi@toto.org",
              :password => "foobar",
              :password_confirmation => "foobar"}
  end

  it "should create a new instance if given valid attributes" do
    User.create!(@attr)
  end

  it "should require a name" do
    no_name_user = User.new(@attr.merge(:name=>''))
    no_name_user.should_not be_valid
  end

  it "should require an email " do
    no_email_user = User.new(@attr.merge(:email=>''))
    no_email_user.should_not be_valid
  end

  it "should reject name too long" do
    long_name = "a"*51
    too_long_name_user = User.new(@attr.merge(:name => long_name))
    too_long_name_user.should_not be_valid
  end

  it "should accept valid email address " do
    addresses = %w[ toto@titi.org TOTO_TITI@foo.com  first.last@domain.jp]
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end

  it "should reject invalid email address" do
    addresses = %w[ titi@toto titi_toto_foo.com first.last@domain. titi@toto,com]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not  be_valid 
    end
  end

  it "should reject duplicate email address" do
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end
  it "should reject duplicate email upcased" do
    upcase_email = @attr[:email].upcase
    User.create!(@attr)
    user_duplicate_upcase_email = User.new(@attr.merge(:email => upcase_email)) 
    user_duplicate_upcase_email.should_not be_valid 
  end

  describe "Password validation" do
    it "should have password" do
      User.new(@attr).should respond_to(:password)
    end
    it "should have password confirmation" do
        User.new(@attr).should respond_to(:password_confirmation)
    end
    it "should not accept empty password" do
      empty_password_user = User.new(@attr.merge(:password => '', :password_confirmation => ''))
      empty_password_user.should_not be_valid
    end

    it "should not accept wrong validation password" do
      wrong_validation_user = User.new(@attr.merge(:password_confirmation => 'wrong password validation'))
      wrong_validation_user.should_not be_valid
    end

    it "should not accept short password" do
      short_password = 'a'*4
      short_password_user = User.new(@attr.merge(:password => short_password, 
                                                  :password_confirmation => short_password))
      short_password_user.should_not be_valid 
    end

    it "should not accept long password" do
      long_password = 'a'*41
      long_password_user = User.new(@attr.merge(:password => long_password, 
                                                 :password_confirmation => long_password))
      long_password_user.should_not be_valid 
    end

    describe "Password Encryption" do
      before(:each) do
        @user = User.create!(@attr)
      end
      it "should have an encrypted password" do
        @user.should respond_to :encrypted_password
      end
      it "encrypted password should not be blank" do
        @user.encrypted_password.should_not be_blank
      end
      it "should have a salt" do
        @user.should respond_to :salt
      end

      describe "has_password? method" do
        it "should be true if passwords match" do
          @user.has_password?(@attr[:password]).should be_true
        end

        it "should be false if passwords don't match" do
          @user.has_password?("invalid password").should be_false
        end
      end

      describe "authenticate method" do
        it "should return nil on email/password mismatch" do
          wrong_password_user = User.authenticate(@attr[:email], "wrong password")
          wrong_password_user.should be_nil 
        end
        it "should return nil if user email doesn't exist" do
          nonexistent_user = User.authenticate("foo@foo.bar", @attr[:password])
          nonexistent_user.should be_nil
        end
        it "should return proper user if email/password match" do
          matching_user = User.authenticate(@attr[:email], @attr[:password])
          matching_user == @user
        end
      end
    end
  end
end

