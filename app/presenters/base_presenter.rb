# Base class for all presenters 
#
class BasePresenter

  # Constructor logic
  #
  def initialize(object,template)
    @object   = object
    @template = template
  end

  private

  # Access @object via named alias
  #
  def self.presents(name)
    define_method(name) do
      @object
    end
  end

  # Slimmer alias for accessing view methods
  #
  def h
    @template
  end

end
