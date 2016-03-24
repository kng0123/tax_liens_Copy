const Page = React.createClass({
  render: function() {
    return <div className='page-container'>
      <div className='page-content'>
        {this.props.children || "Content"}
      </div>
    </div>
  }
})

export default Page
