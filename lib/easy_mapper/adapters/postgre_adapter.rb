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

			def upsert(model, record, primary_keys)
				columns = record.keys.map { |key| "\"#{key}\""}.join(', ')
				placeholders = record.values.map.with_index { |_, i| "$#{i + 1}"}.join(', ')

				size = record.size
				updates = record.keys
					.reject { |key| primary_keys.include? key}
					.map.with_index do |key, index|
						"#{key} = $#{size + index + 1}"
					end.join(', ')

				prepared = """
					INSERT INTO #{table_name(model)}
					VALUES (#{placeholders})
					ON CONFLICT (#{primary_keys.join(',')})
					DO UPDATE SET #{updates}
				"""

				puts prepared
				@connection.prepare('upsert_model', prepared)
				@connection.exec_prepared('upsert_model',
					record.values +
					record.reject { |key, _| primary_keys.include? key}.values)
			end

			def insert(model, record)
				columns = record.keys.map { |key| "\"#{key}\""}.join(', ')
				placeholders = record.values.map.with_index { |_, i| "$#{i + 1}"}.join(', ')

				prepared = """
					INSERT INTO #{table_name(model)} (#{columns})
					VALUES (#{placeholders})
				"""

				@connection.prepare('new_model', prepared)
				@connection.exec_prepared('new_model', record.values)
			end

			def delete(model, query)
				where_clause = query.keys.map.with_index do |key, index|
					"#{key} = $#{index + 1}"
				end.join(' AND ')

				prepared = """
					DELETE FROM #{table_name(model)}
					WHERE #{where_clause}
				"""

				@connection.prepare('delete', prepared)
				@connection.exec_prepared('delete', query.values)
			end

			def update(model, record)
				updates = record.keys.map.with_index do |key, index|
					"#{key} = $#{index + 1}"
				end.join(' AND ')

				prepared = """
					UPDATE #{table_name(model)}
					SET #{updates}
					WHERE id = $#{record.size + 1}
				"""
				puts prepared
				@connection.prepare('update', prepared)
				puts record.values + [record[:id]]
				@connection.exec_prepared('update', record.values + [record[:id]])
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

