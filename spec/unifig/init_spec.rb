require 'tempfile'

RSpec.shared_examples 'basic load tests' do
  context 'with invalid YAML' do
    let(:str) { '`' }

    it 'throws an error' do
      expect { subject }.to raise_error Unifig::YAMLSyntaxError
    end
  end

  context 'with an invalid alias' do
    let(:str) { 'a: *b' }

    it 'throws an error' do
      expect { subject }.to raise_error Unifig::YAMLSyntaxError
    end
  end

  context 'with a valid config' do
    let(:str) do
      <<~YML
        config:
          providers: local

        ONE:
          value: 1
      YML
    end

    it 'loads up a string of yaml' do
      subject

      expect(Unifig).to respond_to(:one)
      expect(Unifig.one).to be 1
    end
  end
end

RSpec.describe Unifig::Init do
  let(:env) { :development }

  describe '.load' do
    subject(:load) { described_class.load(str, env: env) }

    include_examples 'basic load tests'

    context 'from multiple providers' do
      let(:str) do
        <<~YML
          config:
            providers: [local, forty_two]

          ONE:
          TWO:
            value: 2
        YML
      end

      it 'returns the values from the providers in order' do
        load

        expect(Unifig.one).to eql '42'
        expect(Unifig.two).to be 2
      end
    end

    context 'with an optional var' do
      before { load }

      context 'that is available' do
        let(:str) do
          <<~YML
            config:
              providers: local

            ONE:
              optional: true
              value: 1
          YML
        end

        it 'loads the var' do
          expect(Unifig.one).to be 1
        end

        it 'sets the predicate to true' do
          expect(Unifig).to be_one
        end
      end

      context 'that is not available' do
        let(:str) do
          <<~YML
            config:
              providers: local

            ONE:
              optional: true
          YML
        end

        it 'makes the var nil' do
          expect(Unifig.one).to be_nil
        end

        it 'sets the predicate to false' do
          expect(Unifig).to_not be_one
        end
      end

      context 'that is not blank' do
        let(:str) do
          <<~YML
            config:
              providers: local

            ONE:
              optional: true
              value: ' '
          YML
        end

        it 'makes the var nil' do
          expect(Unifig.one).to be_nil
        end

        it 'sets the predicate to false' do
          expect(Unifig).to_not be_one
        end
      end
    end

    context 'with a required var' do
      context 'that is available' do
        before { load }

        let(:str) do
          <<~YML
            config:
              providers: local

            ONE:
              value: 1
          YML
        end

        it 'loads the var' do
          expect(Unifig.one).to be 1
        end

        it 'sets the predicate to true' do
          expect(Unifig).to be_one
        end
      end

      context 'that is not available' do
        let(:str) do
          <<~YML
            config:
              providers: local

            ONE:
              value:
          YML
        end

        it 'throws an error' do
          expect { load }.to raise_error Unifig::MissingRequiredError
        end
      end

      context 'that is blank' do
        let(:str) do
          <<~YML
            config:
              providers: local

            ONE:
              value: ' '
          YML
        end

        it 'throws an error' do
          expect { load }.to raise_error Unifig::MissingRequiredError
        end
      end
    end

    context 'with substitutions' do
      let(:str) do
        <<~YML
          config:
            providers: local

          NAME:
            value: "world"
          GREETING:
            value: "Hello, ${NAME}!"
        YML
      end

      it 'replaces the substitution' do
        load

        expect(Unifig.greeting).to eql 'Hello, world!'
      end

      context 'when they are out of order' do
        let(:str) do
          <<~YML
            config:
              providers: local

            GREETING:
              value: "Hello, ${NAME}!"
            NAME:
              value: "world"
          YML
        end

        it 'replaces the substitution' do
          load

          expect(Unifig.greeting).to eql 'Hello, world!'
        end
      end

      context 'when they chain' do
        let(:str) do
          <<~YML
            config:
              providers: local

            INTRO:
              value: "${GREETING} I'm Aaron."
            NAME:
              value: "world"
            GREETING:
              value: "Hello, ${NAME}!"
          YML
        end

        it 'replaces the substitutions in order' do
          load

          expect(Unifig.intro).to eql "Hello, world! I'm Aaron."
        end
      end

      context 'when they cause a cycle' do
        let(:str) do
          <<~YML
            config:
              providers: local

            A:
              value: "${B}"
            B:
              value: "${C}"
            C:
              value: "${A}"
          YML
        end

        it 'raises an error' do
          expect { load }.to raise_error Unifig::CyclicalSubstitutionError, 'cyclical dependency: A, B, C'
        end
      end

      context 'when they do not exist' do
        let(:str) do
          <<~YML
            config:
              providers: local

            A:
              value: "${B}"
          YML
        end

        it 'raises an error' do
          expect { load }.to raise_error Unifig::MissingSubstitutionError
        end
      end
    end
  end

  describe '.load_file' do
    subject(:load_file) { described_class.load_file(file_path, env: env) }

    let(:file) do
      Tempfile.new(%w[test .yml]).tap do |file|
        file.write(str)
        file.close
      end
    end
    let(:file_path) { file.path }

    include_examples 'basic load tests'
  end
end
