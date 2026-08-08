local M = {}

-- hs.task is userdata with a __gc, so a task nothing references can be
-- collected mid-flight and its callback never fires
local running = {}

-- Without a stream callback hs.task only drains the pipe once the process has
-- exited, so anything larger than the 64k pipe buffer deadlocks: the child
-- blocks in write() and never terminates, which reports as nothing happening
-- at all. The streaming reader is what keeps the pipe moving.
function M.run(path, args, done, onError)
	local task
	local out, err = {}, {}
	local exitCode = nil
	local delivered = false

	local function fail(message)
		if onError then
			onError(message)
		end
	end

	local function collect(stdout, stderr)
		if stdout and stdout ~= "" then
			table.insert(out, stdout)
		end

		if stderr and stderr ~= "" then
			table.insert(err, stderr)
		end
	end

	local function deliver()
		if delivered or exitCode == nil then
			return
		end

		delivered = true
		running[task] = nil

		local text = (table.concat(out):gsub("%s+$", ""))

		if exitCode ~= 0 then
			local message = (table.concat(err):gsub("%s+$", ""))

			-- tools that report errors on stdout still deserve a message
			fail(message ~= "" and message or text)

			return
		end

		if done then
			done(text)
		end
	end

	task = hs.task.new(path, function(code, stdout, stderr)
		collect(stdout, stderr)
		exitCode = code
		-- the stream callback gets one last call after this one, so let it
		-- land before the output is consumed
		hs.timer.doAfter(0, deliver)
	end, function(t, stdout, stderr)
		collect(stdout, stderr)

		if t == nil then
			deliver()
		end

		return true
	end, args)

	if not task then
		fail("could not spawn " .. path)
		return
	end

	running[task] = true
	task:start()
end

return M
