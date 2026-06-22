using Base.Meta
using Plots

println("Enter Function")
user_str = strip(readline())

println("Enter First X Guess")
x_0str = strip(readline())
x_0 = parse(Float64, x_0str)

println("Enter Second X Guess")
x_1str = strip(readline())
x_1 = parse(Float64, x_1str)

println("Enter Steps") # number of steps chosen
n_str = strip(readline())
n = parse(Int, n_str)

global const F_STORE = Ref{Function}()
F_STORE[] = eval(:(x -> $(Meta.parse(user_str))))

x_range = range(-2.5, 2.5, 300)

plot_obj = plot(x_range, F_STORE[].(x_range),
      label="f(x) = $(user_str)",
      color=:blue,
      linewidth=3,
      framestyle = :origin,
      grid=true,
      legend = :outertopright,
      xlims = (-3, 3),
      ylims = (-5, 5),
      size=(800, 600))

steps = 0
tol = 1e-6 # Initialize tolerance

new_next_x = x_1

maxx_val = max(abs(x_0), abs(x_1))
maxy_val = max(abs(F_STORE[](x_0)), abs(F_STORE[](x_1)))

while steps < n && abs(F_STORE[](new_next_x)) > tol

# Calculate the new estimate using Secant method formula
  denominator = F_STORE[](x_1) - F_STORE[](x_0)
  if abs(denominator) < eps(Float64)
      println("Warning: Denominator is too close to zero. Secant method failed to converge early.")
      break
  end
  new_next_x = x_1 - F_STORE[](x_1) * (x_1 - x_0) / denominator

# Only plot 5 steps so it's simple
  if steps < 5
# Plot the point (x_0, F_STORE[](x_0))
    scatter!(plot_obj, [x_0], [F_STORE[](x_0)], label="Iter $(steps): x_{i-1}=$(round(x_0, digits=4))", color=:green, markersize=6)

# Plot the point (x_1, F_STORE[](x_1))
    scatter!(plot_obj, [x_1], [F_STORE[](x_1)], label="Iter $(steps): x_i=$(round(x_1, digits=4))", color=:green, markersize=6)

# Plot the point (new_next_x, 0) which is where the secant crosses the x-axis
    scatter!(plot_obj, [new_next_x], [0], label="Iter $(steps): x_{i+1}=$(round(new_next_x, digits=4))", color=:red, markersize=6)

#Plot the secant line
    secant_slope = (F_STORE[](x_1) - F_STORE[](x_0)) / (x_1 - x_0)
    secant_line(x_val) = F_STORE[](x_1) + secant_slope * (x_val - x_1)
    plot!(plot_obj, x_range, secant_line.(x_range), label="Secant for Iter $(steps)", color=:purple, linestyle=:dot, lw=2, alpha=0.5)
  end

  maxx_val = max(maxx_val, abs(x_1), abs(new_next_x))
  maxy_val = max(maxy_val, abs(F_STORE[](x_1)), abs(F_STORE[](new_next_x)))

# Update x_0 and x_1 for the next iteration
  x_0 = x_1
  x_1 = new_next_x

  steps += 1
end


x_padding = max(1.0, maxx_val * 0.1)
y_padding = max(2.0, maxy_val * 0.2)

plot!(plot_obj,
      xlims=(-maxx_val - x_padding, maxx_val + x_padding),
      ylims=(-maxy_val - y_padding, maxy_val + y_padding),
      legend=:outertopright)
println("Secant method finished in $(steps) steps. Approximate root found at x = $(x_1)")
plot_obj
