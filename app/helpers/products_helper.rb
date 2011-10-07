module ProductsHelper

# Generate a clear field that clears the text
# only if the field is left empty
#
def conditional_clear_field(form,name,text)
  form.text_field name,
                :value    => text,
                :onfocus  => "if(this.value=='#{text}')this.value='';this.style.color='#333333';",
                :onblur   => "if(this.value==''){this.value='#{text}';this.style.color='#999999';}"
end


end
