require 'ipaddr'

RSpec.describe Unifig::Var do
  subject(:var) { described_class.new(name, config, env) }

  let(:name) { :NAME }
  let(:config) { {} }
  let(:env) { :development }

  describe '#method' do
    let(:name) { :'A-B' }

    it 'lowercases and switches dashes to underscores' do
      expect(var.method).to be :a_b
    end
  end

  describe '#value=' do
    it 'writes the value' do
      var.value = 'a'

      expect(var.value).to eql 'a'
    end

    it 'write blank strings as nil' do
      var.value = '   '

      expect(var.value).to be_nil
    end

    it 'freezes the value if no frozen' do
      var.value = 'a'

      expect(var.value).to eql 'a'
      expect(var.value).to be_frozen
    end

    context 'without a type' do
      it 'defaults to string' do
        var.value = 1

        expect(var.value).to eql '1'
      end
    end

    context 'with a type of' do
      context 'string' do
        before do
          config.merge!(convert: 'string')
        end

        it 'converts to a String' do
          var.value = 1

          expect(var.value).to eql '1'
        end
      end

      context 'integer' do
        before do
          config.merge!(convert: 'integer')
        end

        it 'converts to an Integer' do
          var.value = '01'

          expect(var.value).to be 1
        end

        context 'with option' do
          context 'base' do
            before do
              config.merge!(convert: { type: 'integer', base: 2 })
            end

            it 'converts it using the specified base' do
              var.value = '11'

              expect(var.value).to be 3
            end
          end
        end
      end

      context 'float' do
        before do
          config.merge!(convert: 'float')
        end

        it 'converts to a Float' do
          var.value = '01.1'

          expect(var.value).to be 1.1
        end
      end

      context 'decimal' do
        before do
          config.merge!(convert: 'decimal')
        end

        it 'converts to a BigDecimal' do
          var.value = '01.1'

          expect(var.value).to eql BigDecimal('01.1')
        end
      end

      context 'symbol' do
        before do
          config.merge!(convert: 'symbol')
        end

        it 'converts to a Symbol' do
          var.value = 'one'

          expect(var.value).to be :one
        end
      end

      context 'date' do
        before do
          config.merge!(convert: 'date')
        end

        it 'converts to a Date' do
          var.value = '2022-01-02'

          value = var.value
          expect(value).to be_an_instance_of Date
          expect(value.year).to be 2022
          expect(value.month).to be 1
          expect(value.day).to be 2
        end

        context 'with option' do
          context 'format' do
            before do
              config.merge!(convert: { type: 'date', format: '%Y-%m-%d' })
            end

            it 'converts it using the specified format' do
              var.value = '2022-01-02'

              value = var.value
              expect(value).to be_an_instance_of Date
              expect(value.year).to be 2022
              expect(value.month).to be 1
              expect(value.day).to be 2
            end

            it 'throws an error on the wrong input' do
              expect { var.value = '2022-01' }.to raise_error Date::Error
            end
          end
        end
      end

      context 'date_time' do
        before do
          config.merge!(convert: 'date_time')
        end

        it 'converts to a DateTime' do
          var.value = '2022-01-02T03:04:05'

          value = var.value
          expect(value).to be_an_instance_of DateTime
          expect(value.year).to be 2022
          expect(value.month).to be 1
          expect(value.day).to be 2
          expect(value.hour).to be 3
          expect(value.minute).to be 4
          expect(value.second).to be 5
        end

        context 'with option' do
          context 'format' do
            before do
              config.merge!(convert: { type: 'date_time', format: '%Y-%m-%dT%H:%M:%S' })
            end

            it 'converts it using the specified format' do
              var.value = '2022-01-02T03:04:05'

              value = var.value
              expect(value).to be_an_instance_of DateTime
              expect(value.year).to be 2022
              expect(value.month).to be 1
              expect(value.day).to be 2
              expect(value.hour).to be 3
              expect(value.minute).to be 4
              expect(value.second).to be 5
            end

            it 'throws an error on the wrong input' do
              expect { var.value = '2022-01' }.to raise_error DateTime::Error
            end
          end
        end
      end

      context 'time' do
        before do
          config.merge!(convert: 'time')
        end

        it 'converts to a Time' do
          var.value = '2022-01-02T03:04:05'

          value = var.value
          expect(value).to be_an_instance_of Time
          expect(value.year).to be 2022
          expect(value.month).to be 1
          expect(value.day).to be 2
          expect(value.hour).to be 3
          expect(value.min).to be 4
          expect(value.sec).to be 5
        end

        context 'with option' do
          context 'format' do
            before do
              config.merge!(convert: { type: 'time', format: '%Y-%m-%dT%H:%M:%S' })
            end

            it 'converts it using the specified format' do
              var.value = '2022-01-02T03:04:05'

              value = var.value
              expect(value).to be_an_instance_of Time
              expect(value.year).to be 2022
              expect(value.month).to be 1
              expect(value.day).to be 2
              expect(value.hour).to be 3
              expect(value.min).to be 4
              expect(value.sec).to be 5
            end

            it 'throws an error on the wrong input' do
              expect { var.value = '2022-01' }.to raise_error ArgumentError
            end
          end
        end
      end

      context 'invalid' do
        before do
          config.merge!(convert: 'invalid')
        end

        it 'throws an error' do
          expect { var.value = 1 }.to raise_error Unifig::InvalidTypeError
        end
      end

      context 'custom' do
        before do
          config.merge!(convert: 'IPAddr')
        end

        it 'converts to the class provided using .new' do
          var.value = '127.0.0.1'

          value = var.value
          expect(value).to be_an_instance_of IPAddr
          expect(value).to be_ipv4
          expect(value.to_s).to eql '127.0.0.1'
        end

        context 'with a custom method' do
          before do
            config.merge!(convert: { type: 'Encoding', method: 'find' })
          end

          it 'uses the method provided' do
            var.value = 'ascii'

            expect(var.value).to be Encoding::US_ASCII
          end
        end

        context 'with an invalid class' do
          before do
            config.merge!(convert: 'Invalid')
          end

          it 'throws an error' do
            expect { var.value = 'invalid' }.to raise_error Unifig::InvalidTypeError
          end
        end
      end
    end
  end

  describe '#local_value' do
    context 'with no value' do
      it 'returns nil' do
        expect(var.local_value).to be_nil
      end
    end

    context 'with a top level value' do
      let(:value) { 'value' }
      let(:config) do
        {
          value: value
        }
      end

      it 'returns the value' do
        expect(var.local_value).to eql value
      end

      context 'with an override' do
        let(:config) do
          {
            value: "#{value}-1",
            envs: {
              env => {
                value: value
              }
            }
          }
        end

        it 'returns the override' do
          expect(var.local_value).to eql value
        end
      end
    end
  end

  describe '#required?' do
    context 'with no value' do
      it 'returns true' do
        expect(var).to be_required
      end
    end

    context 'with a top level value' do
      let(:value) { 'value' }
      let(:config) do
        {
          optional: true
        }
      end

      it 'returns the value' do
        expect(var).to_not be_required
      end

      context 'with an override' do
        let(:config) do
          {
            optional: false,
            envs: {
              env => {
                optional: true
              }
            }
          }
        end

        it 'returns the override' do
          expect(var).to_not be_required
        end
      end
    end
  end
end
