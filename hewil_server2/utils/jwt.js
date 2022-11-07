const jwt = require("jsonwebtoken");

const JWT_SECRET = process.env.JWT_SECRET;

const generateToken = (user) => {
	return jwt.sign(
		{
			id: user.id,
			username: user.username,
			email: user.email,
			firstName: user.firstName,
			lastName: user.lastName,
		},
		JWT_SECRET
	);
};

const getOrganisation = (token) => {
	const verification = jwt.verify(token, JWT_SECRET);
	return verification.charityOrganisation;
};

const verifyToken = (token) => {
	return jwt.verify(token, JWT_SECRET);
};

module.exports = {
	generateToken,
	verifyToken,
	getOrganisation,
};
