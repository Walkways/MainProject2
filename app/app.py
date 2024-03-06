from website import create_app

# if __name__ == "__main__":
#    app = create_app()
#    app.run(debug=True)

# if __name__ == "__main__":
#    app = create_app()
#    app.run(debug=True, host='0.0.0.0')


if __name__ == "__main__":
    app = create_app()
    app.run(host="0.0.0.0", port=5000)

# if __name__ == "__main__":
#    app = create_app()
#    app.run(host="127.0.0.1", port=5000)



    
