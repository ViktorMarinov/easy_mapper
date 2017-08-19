require_relative '../errors'

require 'pg'

module EasyMapper
	module Adapters
		class PostgreAdapter
			def initialize(host: '127.0.0.1', port: 5432, database: , user:, password:)
				@connection = PGconn.connect(
					hostaddr: host,
					port: port,
					dbname: database,
					user: user,
					password: password)
			end

			def upsert(model, record, primary_keys: [])
				placeholders = record.values.map { |value| escape(value) }.join(', ')

				updates = record
					.reject { |key, _| primary_keys.include? key}
					.map do |key, value|
						"#{key} = #{escape(value)}"
					end.join(', ')

				query = """
					INSERT INTO #{table_name(model)}
					VALUES (#{placeholders})
					ON CONFLICT (#{primary_keys.join(',')})
					DO UPDATE SET #{updates}
				"""

				@connection.exec(query)
			end

			def insert(model, record)
				columns = record.keys.map { |key| "\"#{key}\""}.join(', ')
				placeholders = record.values.map { |value| escape(value) }.join(', ')
				query = """
					INSERT INTO #{table_name(model)} (#{columns})
					VALUES (#{placeholders})
				"""

				@connection.exec(query)
			end

			def delete(model, query)
				where_clause = query.map do |key, value|
					"#{key} = #{escape(value)}"
				end.join(' AND ')

				query = """
					DELETE FROM #{table_name(model)}
					WHERE #{where_clause}
				"""

				@connection.exec(query)
			end

			def update(model, record, primary_keys: [])
				updates = record
					.reject { |key, _| primary_keys.include? key}
					.map do |key, value|
						"#{key} = #{escape(value)}"
					end.join(', ')

				pk_filter = primary_keys
					.map { |key| "#{key} = #{escape(record[key])}"}
					.join(' AND ')

				query = """
					UPDATE #{table_name(model)}
					SET #{updates}
					WHERE #{pk_filter}
				"""

				puts query
				@connection.exec(query)
			end

			def find(model, where, order_by, offset, limit)
				query = "SELECT * FROM #{table_name(model)}"

				unless where.empty?
					where_clause = where.map { |key, value| "#{key} = #{value}" }.join(' AND ')
					query += " WHERE #{where_clause}"
				end

				unless order_by.empty?
					order_by_clause = order_by.map { |key, order| "#{key} #{order}" }.join(', ')
					query += " ORDER BY #{order_by_clause}"
				end

				query += "LIMIT #{limit}" if limit
				query += "OFFSET #{offset}" if offset

				puts query
			end

			private

			def escape(value)
				PG::Connection.quote_connstr(value)
			end

			def table_name(clazz)
				clazz.table_name || generate_name(clazz)
			end

			def generate_name(clazz)
				unless clazz.name
					raise Errors::AnonymousClassError
				end

				if clazz.name[-1] == 's'
					"#{clazz}es"
				else
					"#{clazz}s"
				end
			end
		end
	end
end

