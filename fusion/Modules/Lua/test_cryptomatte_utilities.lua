--[[
Requires   : Fusion 9.0.2+
Optional   : cjson
Created by : Cédric Duriau         [duriau.cedric@live.be]
             Kristof Indeherberge  [xmnr0x23@gmail.com]
             Andrew Hazelden       [andrew@andrewhazelden.com]
Version    : 1.2.8
--]]

local cryptoutils = require("cryptomatte_utilities")

-- utils
function collect_tests(module)
    --[[
    Returns function names detected as test.

    Functions with names starting with "test_" will be picked up.

    :param module: Module to collect test function names of.
    :type module: table[string, function]

    :rtype: table[stri]
    ]]
    local tests = {}
    local substr = "test_"
    for name, _ in pairs(module) do
        if string.sub(name, 1, string.len(substr)) == substr then
            table.insert(tests, name)
        end
    end
    table.sort(tests)
    return tests
end

function run_tests(module)
    --[[
    Detects and runs all test functions of a module.

    :param module: Module to run all tests for.
    :type module: table[string, function]
    ]]
    -- collect all tests from module
    print("collectings test(s) ...")
    local tests = collect_tests(module)
    local ntests = #tests
    print(string.format("detected %s test(s) ...", ntests))

    local count = 0
    for _, name in ipairs(tests) do
        count = count + 1
        local percentage = (count / ntests) * 100
        local percentage_str = string.format("%.0f%%", percentage)
        local padding = string.rep(" ", 4 - string.len(percentage_str))
        percentage_str = string.format("%s%s", padding, percentage_str)
        local report = string.format("[%s] %s ... ", percentage_str, name)

        local status, err = pcall(module[name])
        if status then
            report = string.format("%s [%s]", report, "OK")
        else
            report = string.format("%s [%s]\n%s", report, "FAILED", err)
        end
        print(report)
    end
end

function assert_equal(x, y)
    --[[
    Tests the equality of two variables.

    :rtype: boolean
    ]]
    if x == y then
        return true
    else
        error(string.format("%s\nassertion failed: %s != %s", debug.traceback(), x, y))
    end
end

-- mock funtions
storage = {}

function mock_print(message)
    storage["print_return"] = message
end

function mock_log_level_unset()
    return nil
end

function mock_log_level_error()
    return "0"
end

function mock_log_level_warning()
    return "1"
end

function mock_log_level_info()
    return "2"
end

function mock_self_node()
    return {Name="NODE1"}
end

-- tests
module = {}

function module.test__format_log()
    local old_self = self
    self = mock_self_node()
    assert_equal(cryptoutils._format_log("LEVEL", "MESSAGE"), "[Cryptomatte][NODE1][LEVEL] MESSAGE")
    self = old_self
end

function module.test__get_log_level()
    old_get_env = os.getenv

    -- mock log level not set in environment
    os.getenv = mock_log_level_unset
    local r1 = cryptoutils._get_log_level()
    os.getenv = old_get_env
    assert_equal(r1, 0)

    -- mock log level info set in environment (string -> number cast)
    os.getenv = mock_log_level_info
    local r2 = cryptoutils._get_log_level()
    os.getenv = old_get_env
    assert_equal(r2, 2)
end

function module.test__string_starts_with()
    assert_equal(cryptoutils._string_starts_with("foo_bar", "foo_"), true)
    assert_equal(cryptoutils._string_starts_with("foo_bar", "bar"), false)
end

function module.test__string_ends_with()
    assert_equal(cryptoutils._string_ends_with("foo_bar", "_bar"), true)
    assert_equal(cryptoutils._string_ends_with("foo_bar", "foo"), false)
end

function module.test__string_split()
    result = cryptoutils._string_split("foo, bar,bunny", "([^,]+),?%s*")
    assert_equal(#result, 3)
    expected = {"foo", "bar", "bunny"}
    for i, v in ipairs(result) do
        assert_equal(v, expected[i])
    end
end

function module.test__solve_channel_name()
    -- r
    assert_equal(cryptoutils._solve_channel_name("r"), "r")
    assert_equal(cryptoutils._solve_channel_name("R"), "r")
    assert_equal(cryptoutils._solve_channel_name("red"), "r")
    assert_equal(cryptoutils._solve_channel_name("RED"), "r")

    -- g
    assert_equal(cryptoutils._solve_channel_name("g"), "g")
    assert_equal(cryptoutils._solve_channel_name("G"), "g")
    assert_equal(cryptoutils._solve_channel_name("green"), "g")
    assert_equal(cryptoutils._solve_channel_name("GREEN"), "g")

    -- b
    assert_equal(cryptoutils._solve_channel_name("b"), "b")
    assert_equal(cryptoutils._solve_channel_name("B"), "b")
    assert_equal(cryptoutils._solve_channel_name("blue"), "b")
    assert_equal(cryptoutils._solve_channel_name("BLUE"), "b")

    -- a
    assert_equal(cryptoutils._solve_channel_name("a"), "a")
    assert_equal(cryptoutils._solve_channel_name("A"), "a")
    assert_equal(cryptoutils._solve_channel_name("alpha"), "a")
    assert_equal(cryptoutils._solve_channel_name("ALPHA"), "a")
end

function module.test__get_channel_hierarchy()
    -- TODO
end

function module.test__get_absolute_position()
    local x, y = cryptoutils._get_absolute_position(10, 10, 0.5, 0.5)
    assert_equal(x, 5)
    assert_equal(y, 5)
end

function module.test__is_position_in_rect()
    -- NOTE: fusion rectangles follow mathematical convention, (origin=left,bottom)
    local rect = {left=0, top=10, right=10, bottom=0}
    assert_equal(cryptoutils._is_position_in_rect(rect, 5, 5), true)
    assert_equal(cryptoutils._is_position_in_rect(rect, 12, 5), false)
    assert_equal(cryptoutils._is_position_in_rect(rect, 5, 12), false)
end

function module.test__hex_to_float()
    assert_equal(cryptoutils._hex_to_float("3f800000"), 1.0)
    assert_equal(cryptoutils._hex_to_float("bf800000"), -1.0)
end

function module.test_log_error()
    -- TODO
end

function module.test_log_warning()
    -- TODO
end

function module.test_log_info()
    -- TODO
end

function module.test_get_cryptomatte_metadata()
    -- TODO
end

function module.test_read_manifest_file()
    -- TODO
end

function module.test_decode_manifest()
    -- TODO
end

function module.test_get_matte_names()
    -- TODO
end

run_tests(module)
