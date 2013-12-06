module PgSearch
  module Features
    class Trigram < Feature
      def conditions
        if options[:threshold]
          Arel::Nodes::Grouping.new(
            distance.lteq(1 - options[:threshold])
          )
        else
          Arel::Nodes::Grouping.new(
            Arel::Nodes::InfixOperation.new("%", normalized_document, normalized_query)
          )
        end
      end

      def rank
        Arel::Nodes::Grouping.new(
          Arel::Nodes::InfixOperation.new("-", 1, distance)
        )
      end

      private

      def distance
        Arel::Nodes::Grouping.new(
          Arel::Nodes::InfixOperation.new("<->", normalized_document, normalized_query)
        )
      end

      def normalized_document
        Arel::Nodes::Grouping.new(Arel.sql(normalize(document)))
      end

      def normalized_query
        sanitized_query = connection.quote(query)
        Arel.sql(normalize(sanitized_query))
      end
    end
  end
end
