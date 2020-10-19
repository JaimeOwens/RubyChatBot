module Lita
  module Handlers
    class Calculator < Handler
      route(
        /^calculator\s+(-?\d+\s.\s-?\d+)$/i,
        :respond_with_calculator,
        command: true,
      )
      def respond_with_calculator(response)
        str = response.match_data.captures.first
        str = String(str)
        response.reply "#{resorve(str)}"
      end

      def resorve(input)
        resorver = Processor.new()
        return resorver.task(input)
      end

      Lita.register_handler(self)
    end

    class BigNum
      def get_array(num_str)
        if num_str[0] == '-'
          sign = false
          tail = 1
          num_len = num_str.size - 1
        else
          sign = true
          tail = 0
          num_len = num_str.size
        end
        num_arr = Array.new(num_len, 0)
        i = num_str.size - 1
        j = 0
        while i >= tail do
          num_arr[j] = num_str[i].to_i
          i -= 1
          j += 1
        end
        return num_arr, sign
      end
  
      def initialize(num_str)
        @num, @sign = get_array(num_str) 
      end
  
      def get_num
        return @num
      end
  
      def get_sign
        return @sign
      end
  
      def set_sign(newsign)
        @sign = newsign
      end
    end
  
    class Result
      def remove_zero(res)
        i = 0
        count = 0
        while i < res.size do
          if res[i] == '0'
            count += 1
          else
            break 
          end
          i += 1
        end
        if count != 0
          return res[count..-1]
        else
          return res
        end 
      end
  
      def get_result(num_arr)
        res_str = remove_zero(num_arr.join("").reverse)
        if res_str.empty?
          res_str = "0"
        end
        return res_str
      end    
    end
  
    class CalculatorAdd
      def max(a, b)
        if a > b
          return a
        else
          return b
        end
      end

      def carry(res, k)
        while res[k] >= 10 do
          temp = res[k]
          res[k] = temp % 10
          res[k + 1] += temp / 10
          k += 1
        end
        return res
      end
        
      def add(num1, num2)
        sign1 = num1.get_sign()
        sign2 = num2.get_sign()

        if !sign1 && sign2
          num1.set_sign('+')
          cal_sub = CalculatorSub.new()
          res_str, _ = cal_sub.sub(num2, num1)
        elsif sign1 && !sign2
          num2.set_sign('+')
          cal_sub = CalculatorSub.new()
          res_str, _ = cal_sub.sub(num1, num2)
        elsif !sign1 && !sign2
          res_str, _ = add_proc(num1.get_num(), num2.get_num())
          res_str.insert(0, '-')
        else
          res_str, _ = add_proc(num1.get_num(), num2.get_num())
        end
        return res_str
      end
    
      def add_proc(a_arr, b_arr)
        res = Array.new(max(a_arr.size, b_arr.size) * 2, 0)
        i = 0
        j = 0
        k = 0
        while i < a_arr.size && j < b_arr.size do
          r = a_arr[i] + b_arr[j]
          res[k] += r
          if res[k] >= 10
              carry(res, k)
          end
          # print "#{a_arr[i]} #{b_arr[j]} #{res}\n"
          i += 1
          j += 1
          k += 1
        end
        
        while i < a_arr.size do
          res[k] += a_arr[i]
          # print "#{res}\n"
          i += 1
          k += 1
        end

        while j < b_arr.size do
          res[k] += b_arr[j]
          # print "#{res}\n"
          j += 1
          k += 1
        end

        # k -= 1
        result = Result.new()
        res_str = result.get_result(res)
        return res_str, res
      end
    end
  
    class CalculatorSub
      def max(a, b)
        if a > b
          return a
        else
          return b
        end
      end

      def compare(a_arr, b_arr)
        if a_arr.size > b_arr.size
          return true
        elsif a_arr.size == b_arr.size
          i = a_arr.size - 1
          while i >= 0 do
            if a_arr[i] > b_arr[i]
              return true
            elsif a_arr[i] < b_arr[i]
              return false
            end
            i -= 1
          end
          return true
        else
          return false
        end
      end
    
      def sub(num1, num2)
        sign1 = num1.get_sign()
        sign2 = num2.get_sign()
  
        if !sign1 && sign2
          num2.set_sign('-')
          cal_add = CalculatorAdd.new()
          res_str = cal_add.add(num1, num2)
        elsif sign1 && !sign2
          num2.set_sign('+')
          cal_add = CalculatorAdd.new()
          res_str = cal_add.add(num1, num2)
        elsif !sign1 && !sign2
          res_str, _ = sub_proc(num2.get_num(), num1.get_num())
        else
          res_str, _ = sub_proc(num1.get_num(), num2.get_num())
        end
        return res_str
      end
        
      def sub_proc(a_arr, b_arr)
        res = Array.new(max(a_arr.size, b_arr.size), 0)
        i = 0
        j = 0
        k = 0
        flag = true
  
        if !compare(a_arr, b_arr)
          temp_arr = a_arr
          a_arr = b_arr
          b_arr = temp_arr
          flag = false
        end
  
        while i < a_arr.size && j < b_arr.size do
          r = a_arr[i] - b_arr[j]
          res[k] += r
          if res[k] < 0
            res[k + 1] -= 1
            res[k] += 10
          end
          # print "#{a_arr[i]} #{b_arr[j]} #{res}\n"
          i += 1
          j += 1
          k += 1
        end
  
        while i < a_arr.size do
          res[k] += a_arr[i]
          # print "#{res}"
          i += 1
          k += 1
        end
  
        while j < b_arr.size do
          res[k] += b_arr[j]
          # print "#{res}"
          j += 1
          k += 1
        end
        # k -= 1
        result = Result.new()
        res_str = result.get_result(res)
        if !flag
          res_str.insert(0, '-')
        end
        return res_str, res
      end
    end
  
    class CalculatorMul < CalculatorAdd
      def max(a, b)
        if a > b
          return a
        else
          return b
        end
      end

      def mul(num1, num2)
        sign1 = num1.get_sign()
        sign2 = num2.get_sign()
        sign = sign1 ^ sign2
        if !sign
          return mul_proc(num1.get_num(), num2.get_num())
        else
          return mul_proc(num1.get_num(), num2.get_num()).insert(0, '-')
        end    
      end
    
      def mul_proc(a_arr, b_arr)
        res = Array.new(max(a_arr.size, b_arr.size)*2, 0)
        i = 0
        j = 0
        k = 0
        while j < b_arr.size do
          while i < a_arr.size do
            r = a_arr[i] * b_arr[j]
            res[k] += r
            if(res[k] >= 10)
              carry(res, k)
            end
            # print "#{a_arr[i]} #{b_arr[i]} #{res}\n"
            k += 1
            i += 1
          end
          i = 0
          j += 1
          k = j
        end
        result = Result.new()
        res_str = result.get_result(res)
        return res_str 
      end
    end
    
    class CalculatorDiv < CalculatorSub
      def max(a, b)
        if a > b
          return a
        else
          return b
        end
      end

      def get_t2(length, b_arr)
        if length <= b_arr.size
          return b_arr
        else
          t2_arr = Array.new(length, 0)
          i = length - 1
          j = b_arr.size - 1
          while j >= 0 do
            t2_arr[i] = b_arr[j] 
            i -= 1    
            j -= 1
          end
          return t2_arr
        end
      end
  
      def save_count(quot, count)
        quot.insert(0, 0)
        count_num = BigNum.new(count.to_s)
        cal_add = CalculatorAdd.new()
        _, quot = cal_add.add_proc(quot, count_num.get_num())
        return quot
      end
    
      def div(num1, num2)
        sign1 = num1.get_sign()
        sign2 = num2.get_sign()
        quot_res, remainder_res = div_proc(num1.get_num(), num2.get_num())
        if sign1 ^ sign2 && quot_res != "0"
          quot_res.insert(0, '-')
        end
        if !sign1 && remainder_res != "0"
          remainder_res.insert(0, '-')
        end 
        return quot_res, remainder_res
      end
    
      def div_proc(a_arr, b_arr)
        array_handle = BigNum.new("")
        t1_arr = a_arr
        t2_arr = get_t2(a_arr.size - 1, b_arr)
        quot = Array.new(2, 0)
        # print "t1:#{t1_arr}\nt2:#{t2_arr}\nquot:#{quot}\n" 
        count = 0

        while t1_arr.size >= t2_arr.size do
          while compare(t1_arr, t2_arr) do 
            _, t1_arr = sub_proc(t1_arr, t2_arr)
            if t1_arr[-1] == 0
              t1_arr.pop
            end
            count += 1
            # print "t1:#{t1_arr}\ncount:#{count}\n"
          end

          quot = save_count(quot, count)
          # print "\nt1:#{t1_arr}\nt2:#{t2_arr}\nquot:#{quot}\ncount:#{count}\n\n"
          if t2_arr.size - 1 < b_arr.size
            break
          end
          count = 0
          t2_arr = get_t2(t2_arr.size - 1, b_arr) 
        end

        result = Result.new()
        quot_str = result.get_result(quot)
        remainder_str = result.get_result(t1_arr)

        return quot_str, remainder_str
      end
    end
  
    class Processor 
      def task(input_str)
        @input = input_str
        input_arr = input_str.split(' ')
        @num1 = BigNum.new(input_arr[0])
        @num2 = BigNum.new(input_arr[2])
        @operator = input_arr[1]
        return process()
      end
  
      def process
        if @operator == '+'
          cal_add = CalculatorAdd.new()
          res1, _ = cal_add.add(@num1, @num2)
        elsif @operator == '-'
          cal_sub = CalculatorSub.new()
          res1, _ = cal_sub.sub(@num1, @num2)
        elsif @operator == '*'
          cal_mul = CalculatorMul.new()
          res1, _ = cal_mul.mul(@num1, @num2)
        elsif @operator == '/'
          cal_div = CalculatorDiv.new()
          res1, res2 = cal_div.div(@num1, @num2)
        end
        return output(res1, res2)
      end
  
      def output(res1, res2)
        result = String.new()
        if !res2
          result.concat("#{res1}\n")
        else
          result.concat("#{res1} #{res2}\n")
        end
        return result
      end
    end
  end
end
