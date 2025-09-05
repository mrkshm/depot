require "test_helper"

class ProductTest < ActiveSupport::TestCase
  fixtures :products

  test "cannot create product with missing information" do
    product = Product.new
    assert product.invalid?
    assert product.errors[:title].any?
    assert product.errors[:price].any?
    assert product.errors[:description].any?
    assert product.errors[:image].any?
  end

  test "price must be positive" do
    product = Product.new(title: "wat", description: "wat")
    product.image.attach(io:File.open("test/fixtures/files/lorem.jpg"), filename: 'lorem.jpg', content_type: 'image/jpg')

    product.price = -1
    assert product.invalid?
    assert_equal [ "must be greater than or equal to 0.01" ], product.errors[:price]

    product.price = 0
    assert product.invalid?
    assert_equal [ "must be greater than or equal to 0.01" ], product.errors[:price]

    product.price = 0.02
    assert product.valid?
  end

  def new_product(filename, content_type)
    @product = Product.new(
    title: "wat",
    description: "wat",
    price: 1
    ).tap do |product|
      product.image.attach(io:File.open("test/fixtures/files/#{filename}"), filename:, content_type:)
    end
  end

  test "image url" do
    product = new_product("lorem.jpg", "image/jpeg")
    assert product.valid?, "image/jpg must be valid"

    product = new_product("lorem.svg", "image/svg+xml")
    assert_not product.valid?, "image/svg+xml should not be valid"
  end

  test "product must have unique title" do
    product = Product.new(
      title: products(:pragprog).title,
      description: "wat",
      price: 1
    )
    product.image.attach(io: File.open("test/fixtures/files/lorem.jpg"), filename: 'lorem.jpg', content_type: 'image/jpg')

    assert product.invalid?
    assert_equal [I18n.translate("errors.messages.taken")], product.errors[:title]
  end
end
