module eval_module

export eval_function

function eval_function(interfaces)
  expr = Meta.parse("$interfaces")
  func = eval(:(x -> $expr))
  return func
end

end
