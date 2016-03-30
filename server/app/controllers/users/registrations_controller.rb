# app/controllers/users/registrations_controller.rb
class Users::RegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters, if: :devise_controller?

  def configure_permitted_parameters
     devise_parameter_sanitizer.for(:sign_up) {|u|
       u.permit(:email, :password, :password_confirmation, :remember_me,
       profile_attributes: [:uname, :manager])}
  end
end
