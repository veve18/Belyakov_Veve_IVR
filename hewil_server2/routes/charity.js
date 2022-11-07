




const express = require("express");
const multer = require("multer");
const router = express.Router();
const CharityOrganisation = require("../models/charityOrganisation");
const CharityPost = require("../models/charityPost");
const AnimalShelterPost = require("../models/animalShelterPost");
const { check, validationResult } = require("express-validator");
const bcrypt = require("bcryptjs");
const axios = require("axios");
const sharp = require("sharp");
const cloudinary = require("cloudinary").v2;
const streamifier = require("streamifier");

cloudinary.config({
	cloud_name: "dowtitnpl",
	api_key: "345127211549486",
	api_secret: "TcUCo6tqKqdVb3GZg9YvYn5v-zI",
});

const jwt = require("jsonwebtoken");


const storage = multer.memoryStorage();

const fileFilter = (req, file, cb) => {
	
	if (file.mimetype === "image/heic") {
		axios
			.post("https:
			.then((res) => {
				file.buffer = res.data;
				file.mimetype = "image/jpeg";
				cb(null, true);
			})
			.catch((err) => {
				cb(null, false);
			});
	}
	
	else if (
		file.mimetype === "image/jpeg" ||
		file.mimetype === "image/png" ||
		file.mimetype === "image/jpg"
	) {
		cb(null, true);
	}
	
	else {
		cb(null, false);
	}
};

const upload = multer({
	storage: storage,
	limits: {
		fileSize: 1024 * 1024 * 5,
	},
	fileFilter: fileFilter,
});




router.post(
	"/",
	[
		check("name", "Name is required").not().isEmpty(),
		check("email", "Please include a valid email").isEmail(),
		check("phone", "Phone is required").not().isEmpty(),
		check("city", "City is required").not().isEmpty(),
		check(
			"password",
			"Please enter a password with 6 or more characters"
		).isLength({ min: 6 }),
	],
	async (req, res) => {
		const errors = validationResult(req);
		if (!errors.isEmpty()) {
			return res.status(400).json({ errors: errors.array() });
		}

		var {
			name,
			description,
			email,
			phone,
			address,
			city,
			password,
			contactLink,
		} = req.body;

		if (!description) {
			description = "";
		}

		if (!address) {
			address = "";
		}

		try {
			let charityOrganisation = await CharityOrganisation.findOne({
				where: { email: email },
			});
			if (charityOrganisation) {
				return res.status(400).json({
					errors: [{ msg: "Charity organisation already exists" }],
				});
			}

			charityOrganisation = new CharityOrganisation({
				name,
				description,
				email,
				phone,
				address,
				city,
				password,
				contactLink,
			});

			const salt = await bcrypt.genSalt(10);

			charityOrganisation.password = await bcrypt.hash(password, salt);
			charityOrganisation.salt = salt;

			await charityOrganisation.save();

			const payload = {
				charityOrganisation: {
					id: charityOrganisation.id,
				},
			};

			jwt.sign(payload, process.env.JWT_SECRET, (err, token) => {
				if (err) throw err;
				res.json({ token });
			});
		} catch (err) {
			console.error(err.message);
			res.status(500).send("Server error");
		}
	}
);





router.post(
	"/post",
	loggedInAsCharityOrganisation,
	upload.single("image"),
	[
		check("title", "Title is required").not().isEmpty(),
		check("description", "Description is required").not().isEmpty(),
		check("city", "City is required").not().isEmpty(),
		check("requisites", "Requisites are required").not().isEmpty(),
		check("isPhysical", "isPhysical is required").not().isEmpty(),
	],
	async (req, res) => {
		

		const errors = validationResult(req);
		if (!errors.isEmpty()) {
			return res.status(400).json({ errors: errors.array() });
		}

		
		const charityOrganisation = await CharityOrganisation.findOne({
			where: { id: req.charityOrganisation.id },
		});

		if (!charityOrganisation.isApproved) {
			return res.status(400).json({
				errors: [{ msg: "Charity organisation is not approved" }],
			});
		}

		var { title, description, city, requisites, isPhysical } = req.body;

		try {
			let charityPost = new CharityPost({
				title,
				description,
				city,
				requisites,
				isPhysical,
				charityOrganisationId: req.charityOrganisation.id,
			});

			if (!req.file) {
				
				return res.status(400).json({
					errors: [{ msg: "Image is required" }],
				});
			}

			
			const image = await sharp(req.file.buffer)
				.resize({ width: 500, height: 500, fit: "inside" })
				.toBuffer();

			
			

			let upload_stream = cloudinary.uploader.upload_stream(
				{ folder: "charity-posts" },
				(error, result) => {
					if (error) {
						console.log(error);
						return res.status(500).json({
							errors: [{ msg: "Image upload failed" }],
						});
					}

					charityPost.image = result.secure_url;

					charityPost.save().then((charityPost) => {
						res.json(charityPost);
					});
				}
			);

			streamifier.createReadStream(image).pipe(upload_stream);
		} catch (err) {
			console.error(err);
			console.error(err.message);
			res.status(500).send("Server error");
		}
	}
);


const resizeImage = async (image, width, height) => {
	const resizedImage = await sharp(image)
		.resize(width, height, {
			fit: sharp.fit.inside,
			withoutEnlargement: true,
		})
		.toBuffer();

	return resizedImage;
};





router.post(
	"/shelter/post",
	loggedInAsCharityOrganisation,
	upload.single("image"),
	[
		check("title", "Title is required").not().isEmpty(),
		check("description", "Description is required").not().isEmpty(),
		check("contact", "Contact is required").not().isEmpty(),
		check("city", "City is required").not().isEmpty(),
		check("animal", "Animal is required").not().isEmpty(),
	],
	async (req, res) => {
		const errors = validationResult(req);
		if (!errors.isEmpty()) {
			return res.status(400).json({ errors: errors.array() });
		}

		
		const charityOrganisation = await CharityOrganisation.findOne({
			where: { id: req.charityOrganisation.id },
		});

		if (!charityOrganisation.isApproved) {
			return res.status(400).json({
				errors: [{ msg: "Charity organisation is not approved" }],
			});
		}

		var { title, description, contact, city, animal } = req.body;

		try {
			let shelterPost = new AnimalShelterPost({
				title,
				description,
				contact,
				city,
				animal,
				charityOrganisationId: req.charityOrganisation.id,
			});

			if (!req.file) {
				
				return res.status(400).json({
					errors: [{ msg: "Image is required" }],
				});
			}

			
			const image = await sharp(req.file.buffer)
				.resize({ width: 500, height: 500, fit: "inside" })
				.toBuffer();

			
			

			let upload_stream = cloudinary.uploader.upload_stream(
				{ folder: "shelter-posts" },
				(error, result) => {
					if (error) {
						console.log(error);
						return res.status(500).json({
							errors: [{ msg: "Image upload failed" }],
						});
					}

					shelterPost.image = result.secure_url;

					shelterPost.save().then((shelterPost) => {
						res.json(shelterPost);
					});
				}
			);

			streamifier.createReadStream(image).pipe(upload_stream);
		} catch (err) {
			console.error(err);
			console.error(err.message);
			res.status(500).send("Server error");
		}
	}
);




router.post(
	"/login",
	[
		check("email", "Please include a valid email").isEmail(),
		check("password", "Password is required").exists(),
	],
	async (req, res) => {
		const errors = validationResult(req);
		if (!errors.isEmpty()) {
			return res.status(400).json({ errors: errors.array() });
		}

		const { email, password } = req.body;

		try {
			let charityOrganisation = await CharityOrganisation.findOne({
				where: { email: email },
			});
			if (!charityOrganisation) {
				return res
					.status(400)
					.json({ errors: [{ msg: "Invalid credentials" }] });
			}

			const isMatch = await bcrypt.compare(
				password,
				charityOrganisation.password
			);

			if (!isMatch) {
				return res
					.status(400)
					.json({ errors: [{ msg: "Invalid credentials" }] });
			}

			const payload = {
				charityOrganisation: {
					id: charityOrganisation.id,
				},
			};

			jwt.sign(payload, process.env.JWT_SECRET, (err, token) => {
				if (err) throw err;
				res.json({ token });
			});
		} catch (err) {
			console.error(err.message);
			res.status(500).send("Server error");
		}
	}
);

function loggedInAsCharityOrganisation(req, res, next) {
	

	
	const token =
		req.header("Authorization") &&
		req.header("Authorization").split(" ")[1];

	if (!token) {
		return res.status(401).json({ msg: "No token, authorization denied" });
	}
	try {
		const decoded = jwt.verify(token, process.env.JWT_SECRET);
		req.charityOrganisation = decoded.charityOrganisation;
		next();
	} catch (err) {
		console.log(token);
		res.status(401).json({ msg: "Token is not valid" });
	}
}




router.post(
	"/post",
	loggedInAsCharityOrganisation,
	[
		check("title", "Title is required").not().isEmpty(),
		check("description", "Description is required").not().isEmpty(),
	],
	async (req, res) => {
		const errors = validationResult(req);
		if (!errors.isEmpty()) {
			return res.status(400).json({ errors: errors.array() });
		}

		var { title, description, image, requisites } = req.body;

		if (!image) {
			image = "";
		}

		if (!requisites) {
			requisites = "";
		}

		try {
			const charityOrganisation = await CharityOrganisation.findOne({
				where: { id: req.charityOrganisation.id },
			});

			if (!charityOrganisation) {
				return res.status(400).json({
					errors: [{ msg: "Charity organisation does not exist" }],
				});
			}

			const charityPost = new CharityPost({
				title,
				description,
				image,
				requisites,
				charityOrganisationId: charityOrganisation.id,
			});

			await charityPost.save();

			res.json(charityPost);
		} catch (err) {
			console.error(err.message);
			res.status(500).send("Server error");
		}
	}
);




router.get("/post/:id", async (req, res) => {
	try {
		const charityPost = await CharityPost.findOne({
			where: { id: req.params.id },
		});
		if (!charityPost) {
			return res.status(400).json({ msg: "Charity post not found" });
		}
		res.json(charityPost);
	} catch (err) {
		console.error(err.message);
		res.status(500).send("Server error");
	}
});





router.get("/posts", async (req, res) => {
	try {
		const {
			city,
			charityOrganisationId,
			pageQuery,
			limitQuery,
			organisationScoped,
		} = req.query;
		var where = {
			...(city && { city }),
			...(charityOrganisationId && { charityOrganisationId }),
		};
		if (organisationScoped) {
			where.charityOrganisationId = req.charityOrganisation.id;
		}
		const page = pageQuery ? pageQuery : 1;
		const limit = limitQuery ? limitQuery : 20;
		const offset = (page - 1) * limit;
		const charityPosts = await CharityPost.findAndCountAll({
			order: [["createdAt", "DESC"]],
			where,
			offset,
			limit,
		});
		const charityOrganisations = await CharityOrganisation.findAll({
			where: {
				id: charityPosts.rows.map((charityPost) => {
					return charityPost.charityOrganisationId;
				}),
			},
		});

		
		charityPosts.rows.forEach((charityPost) => {
			charityOrganisations.forEach((charityOrganisation) => {
				if (
					charityPost.charityOrganisationId === charityOrganisation.id
				) {
					charityPost.dataValues.charityOrganisationTitle =
						charityOrganisation.name;
				}
			});
		});
		res.json(charityPosts);
	} catch (err) {
		console.error(err.message);
		res.status(500).send("Server error");
	}
});





router.get("/orgposts", loggedInAsCharityOrganisation, async (req, res) => {
	try {
		const {
			city,
			charityOrganisationId,
			pageQuery,
			limitQuery,
			organisationScoped,
		} = req.query;
		var where = {
			...(city && { city }),
			...(charityOrganisationId && { charityOrganisationId }),
		};
		if (organisationScoped) {
			where.charityOrganisationId = req.charityOrganisation.id;
		}
		const page = pageQuery ? pageQuery : 1;
		const limit = limitQuery ? limitQuery : 20;
		const offset = (page - 1) * limit;
		const charityPosts = await CharityPost.findAndCountAll({
			order: [["createdAt", "DESC"]],
			where,
			offset,
			limit,
		});
		res.json(charityPosts);
	} catch (err) {
		console.error(err.message);
		res.status(500).send("Server error");
	}
});

router.get(
	"/shelter/orgposts",
	loggedInAsCharityOrganisation,
	async (req, res) => {
		try {
			const {
				city,
				charityOrganisationId,
				organisationScoped,
				animal,
				pageQuery,
				limitQuery,
			} = req.query;
			var where = {
				...(city && { city }),
				...(charityOrganisationId && { charityOrganisationId }),
				...(animal && { animals: { [Op.contains]: [animal] } }),
			};
			if (organisationScoped) {
				where.charityOrganisationId = req.charityOrganisation.id;
			}
			const page = pageQuery ? pageQuery : 1;
			const limit = limitQuery ? limitQuery : 20;
			const offset = (page - 1) * limit;
			const charityPosts = await AnimalShelterPost.findAndCountAll({
				order: [["createdAt", "DESC"]],
				where,
				offset,
				limit,
			});
			res.json(charityPosts);
		} catch (err) {
			console.error(err.message);
			res.status(500).send("Server error");
		}
	}
);






router.get("/shelter/posts", async (req, res) => {
	try {
		const { city, charityOrganisationId, animal, pageQuery, limitQuery } =
			req.query;
		const where = {
			...(city && { city }),
			...(charityOrganisationId && { charityOrganisationId }),
			...(animal && { animal }),
		};
		const page = pageQuery ? pageQuery : 1;
		const limit = limitQuery ? limitQuery : 20;
		const offset = (page - 1) * limit;

		
		
		const animalShelterPosts = await AnimalShelterPost.findAndCountAll({
			order: [["createdAt", "DESC"]],
			where,
			offset,
			limit,
		});
		
		const charityOrganisations = await CharityOrganisation.findAll({
			where: {
				id: animalShelterPosts.rows.map(
					(post) => post.charityOrganisationId
				),
			},
		});
		
		animalShelterPosts.rows.forEach((post) => {
			const organisation = charityOrganisations.find(
				(organisation) => organisation.id === post.charityOrganisationId
			);
			post.dataValues.charityOrganisationTitle = organisation.name;
		});
		res.json(animalShelterPosts);
	} catch (err) {
		console.error(err.message);
		res.status(500).send("Server error");
	}
});





router.put("/account", loggedInAsCharityOrganisation, async (req, res) => {
	try {
		const charityOrganisation = await CharityOrganisation.findOne({
			where: { id: req.charityOrganisation.id },
		});
		if (!charityOrganisation) {
			return res
				.status(400)
				.json({ msg: "Charity organisation not found" });
		}
		const { name, description, email, phone, address, city, contactLink } =
			req.body;
		charityOrganisation.name = name;
		charityOrganisation.description = description;
		charityOrganisation.email = email;
		charityOrganisation.phone = phone;
		charityOrganisation.address = address;
		charityOrganisation.city = city;
		charityOrganisation.contactLink = contactLink;
		await charityOrganisation.save();
		res.json(charityOrganisation);
	} catch (err) {
		console.error(err.message);
		res.status(500).send("Server error");
	}
});





router.get("/account", loggedInAsCharityOrganisation, async (req, res) => {
	try {
		const charityOrganisation = await CharityOrganisation.findOne({
			where: { id: req.charityOrganisation.id },
		});
		if (!charityOrganisation) {
			return res
				.status(400)
				.json({ msg: "Charity organisation not found" });
		}
		res.json(charityOrganisation);
	} catch (err) {
		console.error(err.message);
		res.status(500).send("Server error");
	}
});





router.post(
	"/account/userpic",
	loggedInAsCharityOrganisation,
	upload.single("file"),
	async (req, res) => {
		try {
			const charityOrganisation = await CharityOrganisation.findOne({
				where: { id: req.charityOrganisation.id },
			});
			if (!charityOrganisation) {
				return res
					.status(400)
					.json({ msg: "Charity organisation not found" });
			}
			const file = req.file;
			if (!file) {
				return res.status(400).json({ msg: "No file uploaded" });
			}

			
			
			const image = await sharp(file.buffer)
				.resize({ width: 500, height: 500, fit: "inside" })
				.toBuffer();

			
			

			let upload_stream = cloudinary.uploader.upload_stream(
				{ folder: "userpics" },
				(error, result) => {
					if (error) {
						console.log(error);
						return res.status(500).json({
							errors: [{ msg: "Image upload failed" }],
						});
					}
					charityOrganisation.userpicURL = result.secure_url;
					charityOrganisation.save();
					return res.json(charityOrganisation);
				}
			);
			streamifier.createReadStream(image).pipe(upload_stream);
		} catch (err) {
			console.error(err.message);
			res.status(500).send("Server error");
		}
	}
);






router.post("/posts", async (req, res) => {
	const Sequelize = require("sequelize");
	const Op = Sequelize.Op;
	try {
		const post_ids = req.body.post_ids;
		const animalShelterPosts = await AnimalShelterPost.findAll({
			where: {
				id: {
					[Op.in]: post_ids,
				},
			},
		});
		
		const charityOrganisations = await CharityOrganisation.findAll({
			where: {
				id: animalShelterPosts.map(
					(post) => post.charityOrganisationId
				),
			},
		});
		
		animalShelterPosts.forEach((post) => {
			const organisation = charityOrganisations.find(
				(organisation) => organisation.id === post.charityOrganisationId
			);
			post.dataValues.charityOrganisationTitle = organisation.name;
		});

		res.json(animalShelterPosts);
	} catch (err) {
		console.error(err.message);
		res.status(500).send("Server error");
	}
});

module.exports = router;
