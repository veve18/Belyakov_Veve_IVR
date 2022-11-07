var jwt = require("jsonwebtoken");

const JWT_SECRET = process.env.JWT_SECRET;

const isLogginedIn = (req, res, next) => {
	const token = req.header("Authorization");

	if (!token) {
		return res.status(401).json({
			message: "Unauthorized",
		});
	}
	try {
		const decoded = jwt.verify(token, JWT_SECRET);
		req.user = decoded;
		next();
	} catch (error) {
		console.error(error);
		res.status(401).json({
			message: "Unauthorized",
		});
	}
};
