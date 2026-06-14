module SwitchLocale
  extend ActiveSupport::Concern

  private

  def switch_locale(&)
    # Priority is for locale set in query string (mostly for widget/from js sdk)
    locale ||= params[:locale]

    # Use the user's locale if available
    locale ||= locale_from_user

    # Use the locale from a custom domain if applicable
    locale ||= locale_from_custom_domain

    # if locale is not set in account, let's use DEFAULT_LOCALE env variable
    locale ||= ENV.fetch('DEFAULT_LOCALE', 'ar')

    set_locale(locale, &)
  end

  def switch_locale_using_account_locale(&)
    # Get the locale from the user first
    locale = locale_from_user

    # Fallback to the account's locale if the user's locale is not set
    locale ||= locale_from_account(@current_account)

    set_locale(locale, &)
  end

  # If the request is coming from a custom domain, it should be for a helpcenter portal
  # We will use the portal locale in such cases
  def locale_from_custom_domain(&)
    return if params[:locale]
