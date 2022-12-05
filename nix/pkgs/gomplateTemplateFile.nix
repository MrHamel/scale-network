{ stdenv, gomplate }:

{
  gomplateTemplateFile = name: template: data:

    stdenv.mkDerivation {

      name = "${name}";

      nativeBuildInpts = [ gomplate ];

      # Pass Json as file to avoid escaping
      # This sets an environment variable called $jsonDataPath inside the derivation, pointing to the temporary file.
      # The path to the mustache template will be passed directly as another function argument.
      passAsFile = [ "jsonData" ];
      jsonData = builtins.toJSON data;

      # Disable phases which are not needed. In particular the unpackPhase will
      # fail, if no src attribute is set
      phases = [ "buildPhase" "installPhase" ];

      buildPhase = ''
        ${gomplate}/bin/gomplate -d inventory=$jsonDataPath -f ${template} -o rendered_file
      '';

      installPhase = ''
        cp rendered_file $out
      '';
    };
}
