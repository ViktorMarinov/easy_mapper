require 'pg'

module EasyMapper 
	module Adapters
		class PostgreAdapter
			def initialize(host, port, db_name, user, password)
				@connection = PGconn.connect(
					hostaddr: host,
					port: port,
					dbname: db_name,
					user: user,
					password: password)
			end

			def insert(model, record)
				columns = record.keys.map { |key| "\"#{key}\""}.join(', ')
				placeholders = record.values.map.with_index { |_, i| "$#{i + 1}"}.join(', ')
				prepared = "INSERT INTO #{table_name(model)} (#{columns}) VALUES (#{placeholders})"

				@connection.prepare('new_model', prepared)
				@connection.exec_prepared('new_model', record.values)
			end

			def delete(model, query)
				where_clause = query.keys.map.with_index do |key, index|
					"#{key} = $#{index + 1}"
				end.join(' AND ')
				prepared = "DELETE FROM #{table_name(model)} WHERE #{where_clause}"

				@connection.prepare('delete', prepared)
				@connection.exec_prepared('delete', query.values)
			end

			def update(model, record)
				updates = record.keys.map.with_index do |key, index|
					"#{key} = $#{index + 1}"
				end.join(' AND ')

				prepared = "UPDATE #{table_name(model)} SET #{updates} WHERE id = $#{record.size + 1}"
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

			def table_name(class_name)
				if class_name.name[-1] == 's'
					"#{class_name}es"
				else
					"#{class_name}s"
				end
			end
		end
	end
end

