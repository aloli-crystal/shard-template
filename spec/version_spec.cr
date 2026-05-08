require "./spec_helper"
require "yaml"

# Garde-fou contre la désynchronisation entre la constante
# `__MODULE__::VERSION` (lue au compile-time depuis `shard.yml`) et
# la valeur réelle du `version:` du shard.yml.
#
# Si jamais on régresse sur le macro `read_file` dans
# `src/__SHARD__/version.cr`, ce spec rouge alerte immédiatement.
#
# Cf. note mémoire `feedback_shard_version_macro.md`.
describe __MODULE__ do
  it "VERSION matche shard.yml (compile-time read, pas de désynchro)" do
    yml = YAML.parse(File.read(File.join(__DIR__, "..", "shard.yml")))
    __MODULE__::VERSION.should eq(yml["version"].as_s)
  end

  it "VERSION est au format SemVer X.Y.Z (création) ou X.Y.Z.N (portage)" do
    __MODULE__::VERSION.should match(/^\d+\.\d+\.\d+(\.\d+)?$/)
  end
end
