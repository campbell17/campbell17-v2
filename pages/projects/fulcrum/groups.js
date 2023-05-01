import { useState } from 'react';
import Head from 'next/head';
import Layout, { siteTitle } from '../../../components/layout';
import Link from 'next/link';
import Masthead from '../../../components/masthead';
import ContentBlock from '../../../components/contentBlock';
import Gallery from '../../../components/gallery';
import { BlurImage } from '../../../components/gallery';
import Image from 'next/image';

export default function Groups() {
  const [isLoading, setLoading] = useState(true)

  return (
    <Layout fulcrum>
      <Head>
        <title>Case Study</title>
      </Head>
      <Masthead         
        title="Case Study" 
        subtitle="Fulcrum Groups Feature"
      />
      <div style={{ overflow: 'hidden', borderRadius: 8, position: "relative" }}>
        <Image
          alt="Groups Empty State"
          src="/images/groups-empty-new-opt.png"
          layout='responsive'
          width={192}
          height={128}
          objectFit="cover"
          className={
            isLoading
              ? 'gallery-image transitioning'
              : 'gallery-image transitioned'
          }
          onLoadingComplete={() => setLoading(false)}
        />  
      </div>
      <div style={{ border: '1px solid #ddd', borderRadius: 8, padding: '24px 48px', flex: 1, }} className="flex flex-col flex-a-center">
        <div style={{ marginRight: 48 }} className='flex'>
          <p>Provisioning access to Projects, Apps, and Map Layers is fundamental to Fulcrum's end-to-end workflow. Customers with high member count are providing feedback that the current solution is repetitive and time-consuming. How might we streamline this process to address this pain? I lead the design to create an improved solution, allowing customers to provision access more quickly.</p>
        </div>
        <div style={{ width: '100%', justifyContent: 'space-around'}} className='flex'>
          <div style={{ flex: 1, maxWidth: 260 }} className="flex flex-col flex-">
            <h4>My Role</h4>
            <p className="small">I was the sole designer and I took the lead on shaping the workflow, user experience, and UI, as well as finding a way to couple this new feature with the existing way customers provided visibility to these objects.</p>
          </div>
          <div className="flex flex-col flex-">
            <h4>Team</h4>
            <p className="small">Katie Briggs, Product Manager 
            <br/>Chris Louie, Engineering Manager
            <br/>Miguel Malcolm, Engineer
            <br/>Henry Tabimas, Engineer
            <br/>Kevin Osborn, Engineer
            <br/>Juan Miret, Engineer
            <br/>Andres Martin, Engineer
            </p>
          </div>
        </div>
      </div>      
      <ContentBlock
        heading="Problem"
        content="Fulcrum has two primary modes of operation: The web app (dispatch mode) allows Owners/Administrators to set up the Organization by adding team members and creating the forms, projects, and map layers these members will use in the field. The iOS/Android app (collection mode) allows field workers to capture data relevant to the customers' business objectives. Ideally, dispatch mode is intuitive, straightforward, and above all, fast. The faster Owners can get set up, the sooner they can get the data they need."
      >
        <p>Building Forms, creating Projects, and uploading Map Layers takes a reasonable amount of time, but providing visibility of these objects to Organization members is cumbersome, requiring many clicks for each individual. This is defensible for single person Orgs or small teams, but the moment a customer's member count rises into double digits, the amount of time lost to repetitive work is unacceptable.</p>        
      </ContentBlock>

      <div>
        <div style={{position: 'relative', paddingBottom: '56.25%', height: 0}}>
          <iframe src="https://www.loom.com/embed/0266d4d962cd4946a2c9dcb68aea6ffd" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen style={{position: 'absolute', top: 0, left: 0, width: '100%', height: '100%'}}></iframe>
        </div>
        <p className='caption'>Before Groups: Adding App visibility to Members<span className='line'></span></p>
      </div>

      <p>Additionally, one of the perpetual challenges of becoming sticky with customers is lowering the time-to-value, which means any kink in the early stages may deter users from continuing, regardless of whether or not Fulcrum would otherwise satisfy their data collection needs.</p>

      <ContentBlock
        heading="Research"
        content="Through conversations with customers it also became clear that many have their field staff segmented by region or project, and consistently have to alter the visibility access to these objects throughout the year. This wasn't just a pain felt on initial setup, but one that  customers felt every time they embarked on a new project or set up a new region."
      >
        <p>While some power users instituted workarounds utilizing Fulcrum's API, it was clear that a UI-based solution was long overdue.</p>
      </ContentBlock>
    
      <div style={{ overflow: 'hidden', borderRadius: 8, position: "relative" }}>
        <Image
          alt="The genesis of Groups: a Canny request for 'Team Member Management'"
          src="/images/canny-opt.png"
          layout='responsive'
          width={192}
          height={144}
          objectFit="cover"
          className={
            isLoading
              ? 'gallery-image transitioning'
              : 'gallery-image transitioned'
          }
          onLoadingComplete={() => setLoading(false)}          
        />  
      <p className='caption'>The genesis of Groups: a Canny request for "Team Member Management"<span className='line'></span></p>
      </div>

      <ContentBlock
        heading="Opportunity"
        content="Late in 2022 our business objectives shifted to focus more deeply on larger, Enterprise-level organizations and part of that was to look for ways to improve the quality-of-life for the administrators tasked with setting up these accounts. The improved provisioning of Apps, Map Layers, and Projects immediately came to mind as the first step in achieving this."
      >
      </ContentBlock>

      <div style={{ overflow: 'hidden', borderRadius: 8, position: "relative" }}>
        <Image
          alt="Quarterly planning: Groups makes the cut"
          src="/images/pi-opt.png"
          layout='responsive'
          width={192}
          height={140}
          objectFit="cover"
          className={
            isLoading
              ? 'gallery-image transitioning'
              : 'gallery-image transitioned'
          }
          onLoadingComplete={() => setLoading(false)}
        />  
      <p className='caption'>Quarterly planning: Groups makes the cut<span className='line'></span></p>
      </div>

      <ContentBlock
        heading="Exploration, Iteration, Shaping"
        content="Exploration began in Miro, laying out the current state and mapping out the core aspects that needed to be carried over into the new solution."
      >
      </ContentBlock>

      <div style={{ overflow: 'hidden', borderRadius: 8, position: "relative" }}>
        <Image
          alt="Initial audit of the current state of visibility access"
          src="/images/miro-current-opt.png"
          layout='responsive'
          width={192}
          height={128}
          objectFit="cover"
          className={
            isLoading
              ? 'gallery-image transitioning'
              : 'gallery-image transitioned'
          }
          onLoadingComplete={() => setLoading(false)}          
        />  
        <p className='caption'>Initial audit of the current state of visibility access<span className='line'></span></p>
      </div>
      
      <p>The words Team, Group, Folder, Category, and Tag all arose for the concept of a brand new object in Fulcrum that could allow customers to bulk-provision everything to a selection of users. Team was too member-specific and Folder, Category, and Tag were too generic, so "Groups" found the goldilocks zone.</p>

      <h3 style={{ marginBottom: 0 }}>Creating a Group</h3>
      <p>For the first time ever in Fulcrum, customers would be allowed to create an object designed explicitly for the organization of <em>other objects</em> (as opposed to the object itself). This meant designing a scratch-built feature with its own page in the navigation, new components in the design system, and UX/UI patterns to achieve the desired outcome.</p>

      <h3 style={{ marginBottom: 0 }}>New Components</h3>
      <p>Fulcrum is in the midst of establishing a modern design system and the product is in a hybrid state, composed of both old and new techniques and technology. Designing a new feature from the ground up meant creating new components during development and immediately adding them to StoryBook.</p>

      <div className="full-image-container" style={{ overflow: 'hidden', position: "relative" }}>
        <Image
          alt="New components in Figma"
          src="/images/figma-components-opt.png"
          layout='responsive'
          width={192}
          height={128}
          objectFit="cover"
          className={
            isLoading
              ? 'gallery-image transitioning'
              : 'gallery-image transitioned'
          }
          onLoadingComplete={() => setLoading(false)}          
        />  
        <p className='caption'>Selection of new components built for Groups<span className='line'></span></p>
      </div>

      <div className="full-image-container" style={{ overflow: 'hidden', position: "relative" }}>
        <Image
          alt="Detail view of Menu Modal component"
          src="/images/figma-menu-modal-opt.png"
          layout='responsive'
          width={192}
          height={108}
          objectFit="cover"
          className={
            isLoading
              ? 'gallery-image transitioning'
              : 'gallery-image transitioned'
          }
          onLoadingComplete={() => setLoading(false)}          
        />  
        <p className='caption'>Detail view of Menu Modal component from initial concept to latest iteration<span className='line'></span></p>
      </div>

      <h3 style={{ marginBottom: 0 }}>Critical Elements</h3>

      <p>Despite having shiny new components and a new way of toggling object visibility, it wouldn't be that novel if we didn't also add a way to filter down the data and select more than one object at a time. Thus, a prerequisite to making Groups all it could be was adding search, sort, and multi-select to the list components.</p>

      <div style={{ overflow: 'hidden', position: "relative" }}>
        <Image
          alt="Critical elements: search, sort, multi-select"
          src="/images/figma-search-sort-opt.png"
          layout='responsive'
          width={192}
          height={144}
          objectFit="cover"
          className={
            isLoading
              ? 'gallery-image transitioning'
              : 'gallery-image transitioned'
          }
          onLoadingComplete={() => setLoading(false)}          
        />  
        <p className='caption'>Critical elements: search, sort, multi-select<span className='line'></span></p>
      </div>

      <ContentBlock
        heading="Initial Testing and Tweaks"
        content="Sometimes design elements that make sense initially prove clunky or confusing upon deeper scrutiny. Let's take a look at an earlier version of the Group Details screen:"
      >
      </ContentBlock>

      <div style={{ overflow: 'hidden', position: "relative" }}>
        <Image
          alt="Early Group Details screen"
          src="/images/group-details-members-ann-opt.png"
          layout='responsive'
          width={192}
          height={128}
          objectFit="cover"
          className={
            isLoading
              ? 'gallery-image transitioning'
              : 'gallery-image transitioned'
          }
          onLoadingComplete={() => setLoading(false)}          
        />  
      </div>

      <p>The call to action on the Header component seemed like a logical place to add objects to the Group. I also thought it would be nice for users to have a quick way to get to the main screen for each object, so I added a link to each in line with the tab group. </p>

      <p>Even when I built the prototype in Figma, this all seemed logical. But in testing, every time I wanted to add new Members to a Group, I mis-clicked on the link that took me to the Members page instead of clicking on the CTA to open the Members list modal. Moreover, this discovery led to the realization that the CTA on the Header component was sending a mixed message to the user, since it was part of the Header but not related to it. We used this discovery to add notes in StoryBook, specifying that all Header-level CTAs must relate 1:1 with page-level content, as opposed to the sub-page level content it represented in Groups.</p>

      <p>Now I had another problem, though: to where do I move the Add Members CTA? The best place for it based on where I intuitively clicked during testing is where we have the handy navigation link. But upon further inspection, the novelty and usefulness of that button came into question. It was taking up valuable real estate next to the Tabs group, and it didn't really look right having two adjacent CTAs. Also, users can already get to the Members page in 1 click from the SideNav, so I didn't save them any time by putting the link in-page and even worse, I introduced potential confusion. I jettisoned the quick-link and placed the Add Members button there instead.</p>

      <div style={{ overflow: 'hidden', position: "relative" }}>
        <Image
          alt="Critical elements: search, sort, multi-select"
          src="/images/affordances-comparison-opt.png"
          layout='responsive'
          width={192}
          height={108}
          objectFit="cover"
          className={
            isLoading
              ? 'gallery-image transitioning'
              : 'gallery-image transitioned'
          }
          onLoadingComplete={() => setLoading(false)}          
        />  
      </div>

      <p>None of this decision making took place in a vacuum, as the rest of the team helped verify and validate that the changes made sense for the users, as well as for the design patterns we were establishing for future features.</p>

      <div style={{ overflow: 'hidden', position: "relative" }}>
        <Image
          alt="Slack conversation where I announced the broken UX"
          src="/images/slack-testing-opt.png"
          layout='responsive'
          width={192}
          height={108}
          objectFit="cover"
          className={
            isLoading
              ? 'gallery-image transitioning'
              : 'gallery-image transitioned'
          }
          onLoadingComplete={() => setLoading(false)}          
        />  
        <p className='caption'>If it confused me, you can bet it will confuse customers<span className='line'></span></p>
      </div>

      <ContentBlock
        heading="Outcome & Reception"
        content="The addition of Groups to Fulcrum provided a massive step up in speed at scale. Provisioning access is as quick and easy for many users as it is for just a few. (show side-by-side gifs)"
      >
      </ContentBlock>

      <p>As we Beta tested this feature with customers, the feedback was unanimously positive. In fact, despite the backwards compatibility with the original workflow, many customers intimated that this was the only way they would be provisioning access to Members from now on.</p>
      <div>
        <div style={{position: 'relative', paddingBottom: '56.25%', height: 0}}>
          <iframe src="https://www.loom.com/embed/b8584d62ef164bdd9293292432f8ce7e" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen style={{position: 'absolute', top: 0, left: 0, width: '100%', height: '100%'}}></iframe>
        </div>
        <p className='caption'>After Groups: Adding App visibility to Members<span className='line'></span></p>
      </div>
    </Layout>
  );
}