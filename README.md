# Acerola Compute

Acerola Compute (ACompute for short) is a compute shader wrapper language for GLSL compute shaders intended for use with Godot to make compute shader organization, compilation, memory management, and dispatching much simpler.

## Using ACompute Shaders

Because ACompute is technically a custom shader language, it needs its own interpreter which is provided with the script `acerola_shader_compiler.gd`. This must be declared as a global singleton in your Godot project so that on start it will identify any `.acompute` files in your project and compile them automatically. For information on how to do this, please reference [this](https://docs.godotengine.org/en/latest/tutorials/scripting/singletons_autoload.html) tutorial in the Godot documentation.

A more comprehensive tutorial for writing ACompute shaders will be available eventually, but until then, please refer to the provided [examples](https://github.com/GarrettGunnell/Acerola-Compute/tree/main/Examples) which are heavily annotated as well as my video on the creation of the language.

## Planned Features

- Shader file includes
- idk what else please suggest some features
