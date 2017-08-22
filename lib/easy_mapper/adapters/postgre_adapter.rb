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

			def upsert(table, record, primary_keys: [])
				placeholders = record.values.map { |value| escape(value) }.join(', ')

				updates = record
					.reject { |key, _| primary_keys.include? key}
					.map do |key, value|
						"#{key} = #{escape(value)}"
					end.join(', ')

				query = """
					INSERT INTO #{table}
					VALUES (#{placeholders})
					ON CONFLICT (#{primary_keys.join(',')})
					DO UPDATE SET #{updates}
				"""

				puts query
				@connection.exec(query)
			end

			def insert(table, record)
				columns = record.keys.map { |key| "\"#{key}\""}.join(', ')
				placeholders = record.values.map { |value| escape(value) }.join(', ')
				query = """
					INSERT INTO #{table} (#{columns})
					VALUES (#{placeholders})
				"""

				puts query
				@connection.exec(query)
			end

			def delete(table, query)
				where_clause = query.map do |key, value|
					"#{key} = #{escape(value)}"
				end.join(' AND ')

				query = """
					DELETE FROM #{table}
					WHERE #{where_clause}
				"""

				puts query
				@connection.exec(query)
			end

			def update(table, record, primary_keys: [])
				updates = record
					.reject { |key, _| primary_keys.include? key}
					.map do |key, value|
						"#{key} = #{escape(value)}"
					end.join(', ')

				pk_filter = primary_keys
					.map { |key| "#{key} = #{escape(record[key])}"}
					.join(' AND ')

				query = """
					UPDATE #{table}
					SET #{updates}
					WHERE #{pk_filter}
				"""

				puts query
				@connection.exec(query)
			end

			def find(table, where: {}, order_by: {}, offset: nil, limit: nil)
				query = "SELECT * FROM #{table}"

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

				@connection.exec(query)
			end

			private

			def escape(value)
				PG::Connection.quote_connstr(value)
			end
		end
	end
end

