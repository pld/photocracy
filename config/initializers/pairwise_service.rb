port = PRODUCTION ? '' : ''
Pairwise.server({
  :development => {
    :host => "",
    :user => "",
    :pass => "",
    :protocol => "http"
  },
  :test => {
    :host => "",
    :user => "",
    :pass => "",
    :protocol => ""
  },
  :production => {
    :host => "127.0.0.1:#{port}",
    :user => "",
    :pass => "",
    :protocol => "http"
  }
}[(ENV['RAILS_ENV'] || 'development').to_sym])