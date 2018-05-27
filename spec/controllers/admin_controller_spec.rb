require 'rails_helper'

Rails.application.routes.routes.to_a.select{|route| route.path.spec.to_s.match(/^\/admin.*$/)}.each do |route|
  # skip redirect routes, assets
  next unless route.defaults[:controller]

  # skip devise routes
  next if route.defaults[:controller]['devise']

  controller = begin
    "#{route.defaults[:controller]}_controller".camelize.constantize
  rescue
    begin
      "#{route.defaults[:controller].pluralize}_controller".camelize.constantize
    rescue
      nil
    end
  end

  action =route.defaults[:action].to_sym
  admin_login_path = '/users/sign_in'

  describe controller do
    route.instance_variable_get('@request_method_match').each do |verb_matcher|
      verb_matcher_method = verb_matcher.to_s.match(/::(\w*)\z/).try(:[], 1)
      next unless verb_matcher_method
      let(:request_method) { verb_matcher_method.downcase.to_sym }
      let(:params) do
        route.required_parts.each_with_object({}) do |part, object|
          object[part] = 1
        end
      end

      describe "#{verb_matcher_method} ##{action}" do
        subject { send request_method, action, params: params }
        context 'without authorized user' do
          it 'redirects to admin sign in' do
            is_expected.to redirect_to(admin_login_path)
          end
        end
      end
    end
  end
end
