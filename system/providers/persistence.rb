# frozen_string_literal: true

Application.register_provider(:persistence) do
  start do
    target.start :db
    register('container', ROM.container(target['db.config']))
  end
end
