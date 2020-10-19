module Lita
  module Handlers
    class Calendar < Handler
      route(
        /^calendar\s+([1-9][0-9]*-[0-9]+)$/i,
        :respond_with_calendar,
        command: true,
      )
      def respond_with_calendar(response)
        time = response.match_data.captures.first
        time = String(time)
        response.reply "#{get_calendar(time)}"
      end

      def get_1year_days(year)
        if(year % 4 == 0) || ((year % 100 != 0) && (year % 400 == 0))
          return 366
        else
          return 365
        end
      end
    
      def get_sum_days(year)
        i = 1
        sum = 0
        while i < year do
          sum += get_1year_days(i)
          i += 1
        end
        return sum
      end

      def get_calendar(string)
        days = Array[31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

        year_str, month_str = string.split("-")
        year = year_str.to_i
        month = month_str.to_i
        sum = get_sum_days(year)
        firstday = (sum + 1) % 7
        
        if get_1year_days(year) == 366
          days[1] = 29
        end
            
        j = 1
        sum = 0 
        while j < month do
            sum += days[j - 1]
            j += 1
        end
        firstday = ((firstday - 1 + sum) % 7)

        result = " Sun Mon Tue Wed Thu Fri Sat\n"
        j = 0
        while j < firstday do
            result.concat("    ")
            j += 1
        end

        i = 1
        week = firstday
        while i <= days[month - 1] do
            if i < 10
                result.concat("   #{i}")
            else
                result.concat("  #{i}")
            end
            week = (week + 1) % 7
            if(week % 7 == 0)
                result.concat("\n")
            end
            i += 1
        end
        result.concat("\n")

        if get_1year_days(year) == 366 
          result.concat("#{year} is a leap year.\n")
        else
          result.concat("#{year} is not a leap year.\n")
        end

        return result
      end

      Lita.register_handler(self)
    end
  end
end
