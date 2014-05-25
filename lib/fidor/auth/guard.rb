module Fidor::Auth
  # The Guard class looks inside a permission-set hash which holds
  # contexts(controller) as keys and privileges(actions) as values. It returns
  # true/false for a given key/value to lookup.
  #
  class Guard
    # <Hash[Array[Symbol]]>::set on init. Roles are checked in their order
    # inside the top lvl ary
    attr_reader :permissions, :effective_permissions

    def initialize
      @permissions = {} # ruby 1.8.7 ActiveSupport::OrderedHash.new
      @effective_permissions = {}
    end

    # @param [Integer] lvl level
    # @param [Object] permissions
    def add_permissions(lvl, permissions)
      new_lvl = !@permissions[lvl]
      @permissions[lvl] ||= {}
      # manually add each key on the lvl, because Hash.merge!
      # overwrites values instead of adding them up, which
      # causes permissions to be stored incorrectly
      permissions.each do |key, value|
        @permissions[lvl][key] ||= []
        @permissions[lvl][key] += value
        @permissions[lvl][key] = @permissions[lvl][key].uniq
      end
      # If we got a new lvl, let's sort the permissions array
      if new_lvl
        new_permissions = {} #ActiveSupport::OrderedHash.new
        @permissions.sort_by { |k,v| k.to_s }.each {|lvl|
          new_permissions[lvl[0]] = lvl[1]
        }
        @permissions = new_permissions
      end
      redo_effective_permissions_hash
      @permissions
    end


    # Checks the existence of a permission set(privilege+context)
    # @return [Boolean] true if permitted, false if not found on ALL levels
    # @param [Symbol] privilege The privilege(action name) to search for
    # @param [Symbol] context  The context(controller name) to look in
    def check(privilege, context)
      @effective_permissions.empty? || (@effective_permissions[context].present? && @effective_permissions[context].include?(privilege))
    end

    private

    def redo_effective_permissions_hash
      started = false
      @effective_permissions = {}
      @permissions.each do |lvl, perms|
        if perms.present?
          if started
            @effective_permissions.delete_if { |key, current_perms| perms[key].blank? }
            @effective_permissions.each { | key, current_perms | @effective_permissions[key] &= perms[key] }
          else
            @effective_permissions = perms.dup
            started = true
          end
        end
      end
      @effective_permissions
    end
  end # Guard
end # KingAuth
