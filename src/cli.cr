# Point d'entrée CLI optionnel.
#
# Pour l'utiliser : décommenter le bloc `targets:` dans `shard.yml`
# (qui pointe vers ce fichier). Sinon, supprimez ce fichier — le
# module est utilisable en bibliothèque sans CLI.
#
# Conventions UX (cf. notes mémoire ALOLI) :
#
# * `feedback_cli_help_subcommand.md` : tout CLI ALOLI accepte
#   `<cli> help [<sub>]` en positionnel + `-h` + `--help`.
# * `feedback_cli_short_flags.md` : tout flag long doit avoir un
#   short (-X), TOUTES les sous-commandes aussi.

require "option_parser"
require "./__SHARD__"

parser = OptionParser.new do |p|
  p.banner = <<-BANNER
    Usage : __SHARD__ SOUS-COMMANDE [options]

    Sous-commandes :
      # Ajoutez vos sous-commandes ici. Modèles :
      # foo       Description courte
      # bar       Description courte

    Options globales :
    BANNER

  p.on("-v", "--version", "Affiche la version") do
    puts "__SHARD__ #{__MODULE__::VERSION}"
    exit 0
  end
  p.on("-h", "--help", "Affiche cette aide") do
    puts p
    exit 0
  end

  p.invalid_option do |flag|
    STDERR.puts "Option inconnue : #{flag}"
    STDERR.puts p
    exit 1
  end
end

positional = [] of String
parser.unknown_args { |args| positional = args }
parser.parse(ARGV)

# Sous-commande `help` (convention UX ALOLI). Sans argument =
# aide globale (équivalent à --help). Avec argument = focus sur la
# sous-commande demandée. Refus explicite des sous-commandes
# inconnues avec liste valide.
if !positional.empty? && (positional.first == "help" || positional.first == "-h" || positional.first == "--help")
  sub = positional[1]?
  if sub.nil? || sub.empty?
    puts parser
    exit 0
  end
  # ⚠ ADAPTEZ cette liste à vos vraies sous-commandes.
  valid_subs = %w() # of String
  unless valid_subs.includes?(sub.downcase)
    STDERR.puts "Aide indisponible pour « #{sub} » (sous-commandes : #{valid_subs.join(", ")})."
    STDERR.puts "Utilisez `__SHARD__ help` pour l'aide globale."
    exit 1
  end
  full = parser.to_s
  puts full
  puts ""
  puts "─── Focus : #{sub} ───"
  full.lines.each_with_index do |line, i|
    if line.lstrip.starts_with?("#{sub} ") || line.includes?("  #{sub}  ")
      full.lines[i, 6].each { |l| puts l.rstrip }
      break
    end
  end
  exit 0
end

if positional.empty?
  STDERR.puts "Erreur : aucune sous-commande spécifiée"
  STDERR.puts parser
  exit 1
end

case positional.first
  # when "foo"
  #   # … logique foo …
  # when "bar"
  #   # … logique bar …
else
  STDERR.puts "Erreur : sous-commande inconnue « #{positional.first} »"
  STDERR.puts parser
  exit 1
end
