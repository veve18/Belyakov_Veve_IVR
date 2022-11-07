var express = require("express");
var router = express.Router();
var jwt = require("../utils/jwt");
var User = require("../models/user");
var Sequelize = require("sequelize");
var passwords = require("../utils/passwords");
var charityOrganisation = require("../models/charityOrganisation");
var animalShelterPost = require("../models/animalShelterPost");
var charityPost = require("../models/charityPost");

router.get("/", function (req, res, next) {
	res.send("respond with a resource");
});

router.post("/register", async function (req, res, next) {
	try {
		const { username, password, email, firstName, lastName } = req.body;

		const missingFields = [
			username,
			password,
			email,
			firstName,
			lastName,
		].filter((field) => !field);

		if (missingFields.length) {
			return res.status(400).json({
				message: `Missing fields: ${missingFields.join(", ")}`,
			});
		}

		const existingUser = await User.findOne({
			where: {
				[Sequelize.Op.or]: [{ username }, { email }],
			},
		});
		if (existingUser) {
			return res.status(400).json({
				message: "User already exists",
			});
		}

		const { password: hashedPassword, salt } = await passwords.hashPassword(
			password
		);

		const user = await User.create({
			username,
			email,
			firstName,
			lastName,
			password: hashedPassword,
			salt,
		});

		const token = jwt.generateToken(user);

		res.json({
			token,
		});
	} catch (error) {
		console.error(error);
		res.status(500).json({
			message: "Something went wrong",
		});
	}
});

router.post("/login", async function (req, res, next) {
	try {
		const { username, password } = req.body;

		if (!username || !password) {
			return res.status(400).json({
				message: "Missing required fields",
			});
		}

		const user = await User.findOne({
			where: {
				[Sequelize.Op.or]: [{ username }, { email: username }],
			},
		});
		if (!user) {
			return res.status(400).json({
				message: "Invalid username or password",
			});
		}

		const result = await passwords.comparePassword(
			password,
			user.password,
			user.salt
		);
		if (!result) {
			return res.status(400).json({
				message: "Invalid username or password",
			});
		}

		const token = jwt.generateToken(user);

		res.json({
			token,
		});
	} catch (error) {
		console.error(error);
		res.status(500).json({
			message: "Something went wrong",
		});
	}
});

router.put("/edit", jwt.verifyToken, async function (req, res, next) {
	try {
		const { username, email, firstName, lastName } = req.body;
		if (!username || !email || !firstName) {
			return res.status(400).json({
				message: "Missing required fields",
			});
		}
		const user = await User.findByPk(req.user.id);
		if (!user) {
			return res.status(400).json({
				message: "User does not exist",
			});
		}
		const updatedUser = await user.update({
			username: username !== user.username ? username : user.username,
			email: email !== user.email ? email : user.email,
			firstName:
				firstName !== user.firstName ? firstName : user.firstName,
		});
		const token = jwt.generateToken(updatedUser);
		res.json({
			token,
		});
	} catch (error) {
		console.error(error);
		res.status(500).json({
			message: "Something went wrong",
		});
	}
});

router.get("/info", jwt.verifyToken, async function (req, res, next) {
	try {
		const { username } = req.query;
		if (!username) {
			const user = await User.findByPk(req.user.id);
			if (!user) {
				return res.status(400).json({
					message: "User does not exist",
				});
			}
			return res.json({
				username: user.username,
				email: user.email,
				firstName: user.firstName,
				lastName: user.lastName,
			});
		}
		const user = await User.findOne({
			where: {
				username,
			},
		});
		if (!user) {
			return res.status(400).json({
				message: "User does not exist",
			});
		}
		res.json({
			username: user.username,
			email: user.email,
			firstName: user.firstName,
			lastName: user.lastName,
		});
	} catch (error) {
		console.error(error);
		res.status(500).json({
			message: "Something went wrong",
		});
	}
});

router.get("/org", async function (req, res, next) {
	try {
		const { orgID } = req.query;
		var org;
		if (!orgID) {
			if (req.headers.authorization) {
				const token = req.headers.authorization.split(" ")[1];
				const decoded = jwt.getOrganisation(token);
				org = await charityOrganisation.findByPk(decoded.id);
			} else {
				return res.status(400).json({
					message: "Missing required fields",
				});
			}
		}
		if (!org) {
			org = await charityOrganisation.findOne({
				where: {
					id: orgID,
				},
			});
		}

		if (!org) {
			return res.status(400).json({
				message: "Organisation does not exist",
			});
		}
		res.json({
			name: org.name,
			description: org.description,
			address: org.address,
			city: org.city,
			userpicURL: org.userpicURL,
			contactLink: org.contactLink,
		});
	} catch (error) {
		console.error(error);
		res.status(500).json({
			message: "Something went wrong",
		});
	}
});

router.get("/org/posts", async function (req, res, next) {
	try {
		const { orgID } = req.query;
		if (!orgID) {
			return res.status(400).json({
				message: "Missing required fields",
			});
		}
		const org = await charityOrganisation.findOne({
			where: {
				id: orgID,
			},
		});
		if (!org) {
			return res.status(400).json({
				message: "Organisation does not exist",
			});
		}
		const charityPosts = await charityPost.findAll({
			where: {
				charityOrganisationId: orgID,
			},
		});
		const animalShelterPosts = await animalShelterPost.findAll({
			where: {
				charityOrganisationId: orgID,
			},
		});
		res.json({
			charityPosts,
			animalShelterPosts,
		});
	} catch (error) {
		console.error(error);
		res.status(500).json({
			message: "Something went wrong",
		});
	}
});

module.exports = router;
