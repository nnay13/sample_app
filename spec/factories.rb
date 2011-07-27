Factory.define(:user) do |user|
  user.name                  "Yann GUILLOUX"
  user.email                 "toto@titi.org"
  user.password              "foobar"
  user.password_confirmation "foobar"
end
